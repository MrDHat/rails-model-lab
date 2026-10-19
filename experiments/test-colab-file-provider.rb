# Local protocol fixture: no model, Docker, or evaluation task.
require 'tmpdir'
ENV['COLAB_RELAY_DIR'] = Dir.mktmpdir('colab-relay-test-')
ENV['COLAB_MODEL_REVISION'] = 'test-revision'
ENV['COLAB_PREFILL_CHUNK_SIZE'] = '1024'
ENV['COLAB_INPUT_TOKEN_LIMIT'] = '12288'
require_relative 'colab-file-provider'
provider = RubyLLM::Providers::Ollama.new(RubyLLM.config)
model = RubyLLM::Model::Info.default('Qwen/Qwen3.5-4B', 'ollama')

begin
  %i[success runtime_error wrong_revision].each do |scenario|
    worker = Thread.new do
      provider.complete([RubyLLM::Message.new(role: :user, content: 'Transport fixture')],
                        tools: {}, temperature: nil, model: model, params: {max_tokens: 2048})
    end
    worker.report_on_exception = false
    path = nil
    100.times do
      path = Dir[File.join(ENV['COLAB_RELAY_DIR'], '*.request.json')].find do |candidate|
        !File.exist?(candidate.sub('.request.json', '.response.json'))
      end
      break if path
      sleep 0.02
    end
    raise 'request missing' unless path
    request = JSON.parse(File.read(path))
    raise 'bad cap' unless request['max_new_tokens'] == 2048
    raise 'input budget lost' unless request['input_token_limit'] == 12288
    raise 'protocol missing' unless request['relay_protocol'] == 3
    raise 'deadline missing' unless Time.iso8601(request.fetch('expires_at')) - Time.iso8601(request.fetch('created_at')) == 600
    raise 'prefill setting lost' unless request['prefill_chunk_size'] == 1024
    response = {relay_id: request.fetch('id'), revision: 'test-revision', model: model.id}
    if scenario == :success
      response.merge!(choices: [{finish_reason: 'tool_calls', message: {
        role: 'assistant', content: 'Fixture', tool_calls: [{id: 'fixture', type: 'function',
          function: {name: 'bash', arguments: JSON.generate(command: 'echo fixture')}}]
      }}], usage: {prompt_tokens: 10, completion_tokens: 5})
    else
      response[:error] = {type: 'OutOfMemoryError', message: 'CUDA fixture'}
      response[:revision] = 'wrong' if scenario == :wrong_revision
    end
    destination = path.sub('.request.json', '.response.json')
    File.write("#{destination}.tmp", JSON.generate(response))
    File.rename("#{destination}.tmp", destination)
    if scenario == :success
      message = worker.value
      raise 'tokens lost' unless message.input_tokens == 10 && message.output_tokens == 5
      raise 'command changed' unless message.tool_calls.fetch('fixture').arguments.fetch('command') == 'echo fixture'
      receipt = JSON.parse(File.read(path.sub('.request.json', '.consumed.json')))
      raise 'consumption not recorded' unless receipt['relay_id'] == request['id'] && receipt['parsed_at']
    else
      begin
        worker.value
        raise 'infrastructure failure was accepted as an answer'
      rescue Miniswen::InfrastructureError => error
        expected = scenario == :runtime_error ? 'Colab OutOfMemoryError: CUDA fixture' : 'identity or revision mismatch'
        raise 'wrong error' unless error.message.include?(expected)
      end
      raise 'failed response consumed' if File.exist?(path.sub('.request.json', '.consumed.json'))
    end
  end
  # Simulate a deadline passing while the consumer is asleep, then place a
  # response before it wakes. A file's existence must not override timeout.
  ColabFileProvider.send(:remove_const, :RESPONSE_TIMEOUT)
  ColabFileProvider.const_set(:RESPONSE_TIMEOUT, 0.05)
  worker = Thread.new do
    provider.complete([], tools: {}, temperature: nil, model: model)
  end
  worker.report_on_exception = false
  sleep 0.1
  path = Dir[File.join(ENV['COLAB_RELAY_DIR'], '*.request.json')].find do |candidate|
    !File.exist?(candidate.sub('.request.json', '.response.json'))
  end
  raise 'timeout request missing' unless path
  File.write(path.sub('.request.json', '.response.json'), '{}')
  begin
    worker.value
    raise 'late response accepted'
  rescue Miniswen::InfrastructureError => error
    raise 'wrong timeout error' unless error.message.include?('timed out')
  end
  raise 'timeout not recorded' unless File.exist?(path.sub('.request.json', '.expired.json'))
  raise 'late response consumed' if File.exist?(path.sub('.request.json', '.consumed.json'))
  puts 'Transport fixtures passed: command/tokens, runtime error, revision mismatch'
ensure
  FileUtils.remove_entry(ENV.fetch('COLAB_RELAY_DIR'))
end
