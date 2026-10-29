# frozen_string_literal: true

# Synthetic only. Exercises the real installed adapter and command jail without
# GPU inference, task instructions, grading, public ports, or Modal credentials.
require_relative "installed-modal-transport"
require "lemans/environments/docker"
require "socket"
require "tmpdir"
require "ostruct"

external = ENV["SYNTHETIC_BRIDGE_BASE"]
server = TCPServer.new("127.0.0.1", 0) unless external
ENV["GPUSTACK_API_BASE"] = external || "http://127.0.0.1:#{server.addr[1]}/v1"
ENV["MODAL_BRIDGE_TOKEN"] = SecureRandom.hex(32) unless external
RubyLLM.configure { |config| config.gpustack_api_base = ENV.fetch("GPUSTACK_API_BASE") }
requests = []
fake = Thread.new do
  2.times do |index|
    client = server.accept
    client.gets
    headers = {}
    while (line = client.gets) && line != "\r\n"
      key, value = line.split(":", 2)
      headers[key.downcase] = value.strip
    end
    raise "Host auth missing" unless headers["authorization"] == "Bearer #{ENV.fetch('MODAL_BRIDGE_TOKEN')}"
    request = JSON.parse(client.read(Integer(headers.fetch("content-length"))))
    requests << request
    command = index.zero? ? "test -z \"$GPUSTACK_API_BASE\" && test -z \"$GPUSTACK_API_KEY\" && printf 'installed-check'" : "echo COMPLETE_TASK_AND_SUBMIT_FINAL_OUTPUT"
    body = JSON.generate(id: "synthetic-#{index}", object: "chat.completion", created: Time.now.to_i,
      model: "Qwen/Qwen3.5-4B", choices: [{ index: 0, finish_reason: "tool_calls", message: {
        role: "assistant", content: nil, tool_calls: [{ id: "call-#{index}", type: "function", function: {
          name: "bash", arguments: JSON.generate(command:) } }] } }],
      usage: { prompt_tokens: 100, completion_tokens: 10, total_tokens: 110 })
    client.write("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}")
    client.close
  end
end unless external
fake.report_on_exception = false if fake

settings = Lemans::Config::Environment.new
environment = Lemans::Environments::Docker.new(
  image: Lemans::Config::ImageSpec.registry(ENV.fetch("SYNTHETIC_IMAGE", "lemans-a437e71aa43bc751abd5bed6d6741ff8:latest")),
  resources: settings.resources, network: Lemans::Config::NetworkPolicy.new(mode: "public"))
begin
  environment.start
  environment.exec!("mkdir -p /synthetic && gem install miniswen -v #{Miniswen::VERSION} --no-document", timeout: 300)
  environment.switch_network_policy!(Lemans::Config::NetworkPolicy.new(mode: "allowlist", hosts: ["openrouter.ai", "api.z.ai"]))
  profile = Lemans::Config::Agent.new("miniswen-installed", "gpustack/Qwen/Qwen3.5-4B")
  profile.timeout = 120
  profile.step_limit = 2
  profile.exec_timeout = 5
  agent = Lemans::Agents::MiniswenInstalled.new(profile:)
  identity = ENV.fetch("SYNTHETIC_AGENT_ID", "single")
  raise "Invalid synthetic identity" unless identity.match?(/\A[a-z0-9-]+\z/)
  task = OpenStruct.new(instruction: "Synthetic transport check only. isolated-agent-#{identity}", environment: OpenStruct.new(workdir: "/synthetic"))
  result = agent.run(task, environment)
  raise result.error if result.error?
  raw = JSON.parse(result.raw_result)
  raise "Not submitted" unless raw.fetch("status") == "submitted" && raw.fetch("steps") == 2
  if external
    observed = environment.exec!("cat /synthetic/isolation.txt", timeout: 5)
    raise "Sandbox marker missing" unless observed.output.strip == "installed-check-#{identity}"
  else
    raise "Tool observation missing" unless requests.last.fetch("messages").any? { |m| m["role"] == "tool" && m["content"].to_s.include?("installed-check") }
  end
  ports = JSON.parse(`docker inspect #{environment.container}`).first.fetch("NetworkSettings").fetch("Ports")
  raise "Unexpected published port" unless ports.nil? || ports.values.all?(&:nil?)
  puts JSON.generate(synthetic: "passed", adapter: agent.name, jail: true, steps: raw["steps"], requests: requests.size, published_ports: 0, gpu_calls: 0)
ensure
  environment.stop
  server&.close
  fake&.kill
end
