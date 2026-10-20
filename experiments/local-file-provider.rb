# frozen_string_literal: true

# File transport for local MLX inference. Reuse RubyLLM's Ollama serializers;
# miniswen's prompts, tools, execution loop and the lemans grader stay unchanged.
require "miniswen"
require "fileutils"
require "time"

module LocalFileProvider
  RESPONSE_TIMEOUT = 600

  def complete(messages, tools:, temperature:, model:, params: {}, **)
    directory = ENV.fetch("LOCAL_RELAY_DIR")
    FileUtils.mkdir_p(directory)
    id = SecureRandom.uuid
    started_at = Time.now.utc
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + RESPONSE_TIMEOUT
    request = {
      id: id, model: model.id, relay_protocol: 3,
      created_at: started_at.iso8601(6),
      expires_at: (started_at + RESPONSE_TIMEOUT).iso8601(6),
      messages: format_messages(messages),
      tools: tools.map { |_, tool| tool_for(tool) },
      max_new_tokens: params.fetch(:max_tokens, 1024),
      input_token_limit: Integer(ENV.fetch("LOCAL_INPUT_TOKEN_LIMIT", "8192")),
      prefill_chunk_size: Integer(ENV.fetch("LOCAL_PREFILL_CHUNK_SIZE", "0")).then { |size| size.zero? ? nil : size },
      enable_thinking: false, do_sample: false
    }
    path = File.join(directory, "#{id}.request.json")
    File.write("#{path}.tmp", JSON.generate(request))
    File.rename("#{path}.tmp", path)
    warn "Local request ready: #{path}"
    response_path = File.join(directory, "#{id}.response.json")
    loop do
      if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
        expired = File.join(directory, "#{id}.expired.json")
        File.write("#{expired}.tmp", JSON.generate(
          relay_id: id, expired_at: Time.now.utc.iso8601(6)
        ))
        File.rename("#{expired}.tmp", expired)
        raise Miniswen::InfrastructureError, "Local response timed out for #{id}"
      end
      break if File.exist?(response_path)
      sleep 0.25
    end
    data = JSON.parse(File.read(response_path))
    unless data.fetch("relay_id") == id && data.fetch("revision") == ENV.fetch("LOCAL_MODEL_REVISION")
      raise Miniswen::InfrastructureError, "Local response identity or revision mismatch"
    end
    if data.key?("error")
      error = data.fetch("error")
      raise Miniswen::InfrastructureError, "Local #{error.fetch('type')}: #{error.fetch('message')}"
    end
    message = parse_completion_response(Struct.new(:body).new(data))
    # A response file can arrive after timeout. Only the consumer can attest
    # that it parsed an answer; this receipt does not imply command execution.
    receipt = File.join(directory, "#{id}.consumed.json")
    File.write("#{receipt}.tmp", JSON.generate(
      relay_id: id, revision: data.fetch("revision"), parsed_at: Time.now.utc.iso8601(6)
    ))
    File.rename("#{receipt}.tmp", receipt)
    message
  end
end

raise "LOCAL_RELAY_DIR is required" if ENV["LOCAL_RELAY_DIR"].to_s.empty?
RubyLLM.configure { |config| config.ollama_api_base = "http://unused.invalid" }
RubyLLM::Providers::Ollama.prepend(LocalFileProvider)

# This pinned checkpoint has no hosted API token price. Keep the bundled model
# registry; refreshing remote price lists is irrelevant to this local provider.
module LocalBundledRegistry
  def refresh_registry!(persist: false)
    warn "Local inference: using bundled RubyLLM registry (no remote pricing refresh)"
    true
  end
end
Miniswen.singleton_class.prepend(LocalBundledRegistry)
