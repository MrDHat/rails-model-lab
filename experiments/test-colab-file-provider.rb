# Local protocol fixture: no model, Docker, or evaluation task.
require 'tmpdir'
ENV['COLAB_RELAY_DIR'] = Dir.mktmpdir('colab-relay-test-')
ENV['COLAB_MODEL_REVISION'] = 'test-revision'
require_relative 'colab-file-provider'
provider = RubyLLM::Providers::Ollama.new(RubyLLM.config)
model = RubyLLM::Model::Info.default('Qwen/Qwen3.5-4B', 'ollama')

begin
  %i[success runtime_error wrong_revision].each do |scenario|
    worker = Thread.new do
      provider.complete([RubyLLM::Message.new(role: :user, content: 'Transport fixture')],
                        tools: {}, temperature: nil, model: model, params: {max_tokens: 1024})
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
    raise 'bad cap' unless request['max_new_tokens'] == 1024
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
    else
      begin
        worker.value
        raise 'infrastructure failure was accepted as an answer'
      rescue Miniswen::InfrastructureError => error
        expected = scenario == :runtime_error ? 'Colab OutOfMemoryError: CUDA fixture' : 'identity or revision mismatch'
        raise 'wrong error' unless error.message.include?(expected)
      end
    end
  end
  puts 'Transport fixtures passed: command/tokens, runtime error, revision mismatch'
ensure
  FileUtils.remove_entry(ENV.fetch('COLAB_RELAY_DIR'))
end
