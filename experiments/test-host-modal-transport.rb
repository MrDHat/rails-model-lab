# frozen_string_literal: true

# Synthetic only: exercise the unmodified upstream host agent with a private
# loopback provider, Docker command execution and no GPU or benchmark inputs.
require "lemans"
require "lemans/agents/miniswen"
require "lemans/environments/docker"
require "socket"
require "securerandom"
require "ostruct"

server = TCPServer.new("127.0.0.1", 0)
token = SecureRandom.hex(32)
RubyLLM.configure do |config|
  config.gpustack_api_base = "http://127.0.0.1:#{server.addr[1]}/v1"
  config.gpustack_api_key = token
  config.max_retries = 0
  config.request_timeout = 30
end
requests = []
provider = Thread.new do
  2.times do |step|
    client = server.accept
    begin
      raise "Unexpected provider route" unless client.gets.start_with?("POST /v1/chat/completions ")
      headers = {}
      while (line = client.gets) && line != "\r\n"
        key, value = line.split(":", 2)
        headers[key.downcase] = value.strip
      end
      raise "Provider authorization missing" unless headers["authorization"] == "Bearer #{token}"
      requests << JSON.parse(client.read(Integer(headers.fetch("content-length"))))
      command = step.zero? ? "test -z \"$GPUSTACK_API_BASE\" && test -z \"$GPUSTACK_API_KEY\" && printf 'synthetic-host-marker' > isolation.txt && cat isolation.txt" : "echo COMPLETE_TASK_AND_SUBMIT_FINAL_OUTPUT"
      body = JSON.generate(id: "synthetic-host-#{step}", object: "chat.completion", created: Time.now.to_i,
        model: "Qwen/Qwen3.5-4B", choices: [{ index: 0, finish_reason: "tool_calls", message: {
          role: "assistant", content: nil, tool_calls: [{ id: "host-call-#{step}", type: "function",
            function: { name: "bash", arguments: JSON.generate(command:) } }] } }],
        usage: { prompt_tokens: 100, completion_tokens: 10, total_tokens: 110 })
      client.write("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}")
    ensure
      client.close
    end
  end
end
provider.report_on_exception = false

settings = Lemans::Config::Environment.new
environment = Lemans::Environments::Docker.new(
  image: Lemans::Config::ImageSpec.registry(ENV.fetch("SYNTHETIC_IMAGE")),
  resources: settings.resources, network: Lemans::Config::NetworkPolicy.new(mode: "public"))
begin
  environment.start
  environment.exec!("mkdir -p /synthetic-host", timeout: 10)
  environment.switch_network_policy!(Lemans::Config::NetworkPolicy.new(mode: "allowlist", hosts: ["openrouter.ai", "api.z.ai"]))
  profile = Lemans::Config::Agent.new("miniswen", "gpustack/Qwen/Qwen3.5-4B")
  profile.timeout = 60
  profile.step_limit = 2
  profile.exec_timeout = 5
  task = OpenStruct.new(instruction: "Synthetic host transport only; work in /synthetic-host.",
                        environment: OpenStruct.new(workdir: "/synthetic-host"))
  result = Lemans::Agents::Miniswen.new(profile:).run(task, environment)
  raise result.error if result.error?
  raw = JSON.parse(result.raw_result)
  raise "Host agent did not submit in two steps" unless raw.fetch("status") == "submitted" && raw.fetch("steps") == 2
  raise "Expected two requests" unless requests.size == 2
  raise "Tool observation missing" unless requests.last.fetch("messages").any? { |m| m["role"] == "tool" && m["content"].to_s.include?("synthetic-host-marker") }
  marker = environment.exec!("cat isolation.txt", timeout: 5)
  raise "Sandbox marker missing" unless marker.output.strip == "synthetic-host-marker"
  ports = JSON.parse(`docker inspect #{environment.container}`).first.fetch("NetworkSettings").fetch("Ports")
  raise "Unexpected published ports" unless ports.nil? || ports.values.all?(&:nil?)
  raise "Provider thread did not finish" unless provider.join(5)
  provider.value
  puts JSON.generate(synthetic: "passed", adapter: "miniswen", steps: raw["steps"], requests: requests.size,
                     usage: result.usage.to_h, published_ports: 0, gpu_calls: 0)
ensure
  environment.stop
  server.close
  provider.kill
end
