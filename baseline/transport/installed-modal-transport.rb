# frozen_string_literal: true

# Transport-only adapter: preserve upstream installed agent, jail and policies.
# The local provider bridge owns remote inference and raw evidence. Only a
# disposable loopback token, never Modal credentials, enters the sandbox.
require "lemans"
require "lemans/agents/miniswen_installed"
require "net/http"
require "open3"
require "securerandom"

module InstalledModalTransport
  class Relay
    attr_reader :port, :token

    def initialize(environment)
      raise "Docker backend required" unless environment.is_a?(Lemans::Environments::Docker)
      @base = URI(ENV.fetch("GPUSTACK_API_BASE") + "/chat/completions")
      raise "Host bridge must be loopback" unless @base.scheme == "http" && @base.host == "127.0.0.1"
      @token = SecureRandom.hex(32)
      source = File.read(File.join(__dir__, "sandbox-inference-relay.rb"))
      @input, @output, @errors, @process = Open3.popen3(
        "docker", "exec", "-i", "--env", "SANDBOX_RELAY_TOKEN=#{token}",
        environment.container, "ruby", "-e", source
      )
      raise "Sandbox relay startup timed out" unless IO.select([@output], nil, nil, 15)
      @port = JSON.parse(@output.gets || raise("Sandbox relay exited")).fetch("port")
      @worker = Thread.new do
        while (line = @output.gets)
          request = JSON.parse(line).fetch("request")
          begin
            response = Net::HTTP.start(@base.host, @base.port, nil,
              read_timeout: 1560, open_timeout: 5, max_retries: 0) do |http|
              message = Net::HTTP::Post.new(@base.request_uri)
              message["Content-Type"] = "application/json"
              message["Authorization"] = "Bearer #{ENV.fetch('MODAL_BRIDGE_TOKEN')}"
              message.body = JSON.generate(request)
              http.request(message)
            end
            answer = { status: response.code.to_i, body: response.body }
          rescue StandardError => error
            answer = { status: 502, body: JSON.generate(error: { message: error.message }) }
          end
          @input.puts(JSON.generate(answer))
          @input.flush
        end
      end
      @worker.report_on_exception = false
    rescue StandardError
      close
      raise
    end

    def close
      @input&.close unless @input&.closed?
      Process.kill(:TERM, @process.pid) if @process&.alive?
      @process&.join(3)
      @worker&.kill
      [@output, @errors].compact.each { |io| io.close unless io.closed? }
    rescue Errno::ESRCH, IOError
      nil
    end
  end

  def obtain_result(task, environment, history)
    environment.upload(File.join(__dir__, "installed-modal-config.rb"), "/var/lib/miniswen/modal-config.rb")
    @modal_relay = Relay.new(environment)
    super
  ensure
    @modal_relay&.close
    @modal_relay = nil
  end

  def provider_env(environment)
    super.merge("GPUSTACK_API_BASE" => "http://127.0.0.1:#{@modal_relay.port}/v1",
      "GPUSTACK_API_KEY" => @modal_relay.token,
      "RUBYOPT" => "-r/var/lib/miniswen/modal-config.rb")
  end
end

Lemans::Agents::MiniswenInstalled.prepend(InstalledModalTransport)
