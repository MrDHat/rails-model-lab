# frozen_string_literal: true

# Opt-in transport for an interactive Colab pilot. Miniswen's prompts, tools,
# execution loop and grader are unchanged. No inference endpoint is exposed.
require "miniswen"
require "fileutils"

module ColabFileProvider
  def complete(messages, tools:, temperature:, model:, params: {}, **)
    directory = ENV.fetch("COLAB_RELAY_DIR")
    FileUtils.mkdir_p(directory)
    id = SecureRandom.uuid
    request = {
      id: id, model: model.id,
      messages: format_messages(messages),
      tools: tools.map { |_, tool| tool_for(tool) },
      max_new_tokens: params.fetch(:max_tokens, 1024),
      input_token_limit: Integer(ENV.fetch("COLAB_INPUT_TOKEN_LIMIT", "8192")),
      prefill_chunk_size: Integer(ENV.fetch("COLAB_PREFILL_CHUNK_SIZE", "0")).then { |size| size.zero? ? nil : size },
      enable_thinking: false, do_sample: false
    }
    path = File.join(directory, "#{id}.request.json")
    File.write("#{path}.tmp", JSON.generate(request))
    File.rename("#{path}.tmp", path)
    warn "Colab request ready: #{path}"
    response_path = File.join(directory, "#{id}.response.json")
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 600
    until File.exist?(response_path)
      if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
        raise Miniswen::InfrastructureError, "Colab response timed out for #{id}"
      end
      sleep 0.25
    end
    data = JSON.parse(File.read(response_path))
    unless data.fetch("relay_id") == id && data.fetch("revision") == ENV.fetch("COLAB_MODEL_REVISION")
      raise Miniswen::InfrastructureError, "Colab response identity or revision mismatch"
    end
    if data.key?("error")
      error = data.fetch("error")
      raise Miniswen::InfrastructureError, "Colab #{error.fetch('type')}: #{error.fetch('message')}"
    end
    parse_completion_response(Struct.new(:body).new(data))
  end
end

raise "COLAB_RELAY_DIR is required" if ENV["COLAB_RELAY_DIR"].to_s.empty?
RubyLLM.configure { |config| config.ollama_api_base = "http://unused.invalid" }
RubyLLM::Providers::Ollama.prepend(ColabFileProvider)

# This pinned checkpoint has no hosted API token price. Keep the bundled model
# registry; refreshing remote price lists is irrelevant to this local provider.
module ColabBundledRegistry
  def refresh_registry!(persist: false)
    warn "Colab pilot: using bundled RubyLLM registry (no remote pricing refresh)"
    true
  end
end
Miniswen.singleton_class.prepend(ColabBundledRegistry)
