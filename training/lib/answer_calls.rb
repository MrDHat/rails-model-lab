require 'rbconfig'
require 'tempfile'

# Names of the methods the answer calls while its task's behaviour tests run.
# A call counts only if it actually runs, so dead code earns nothing.
# Calls on integer literals are recorded as `integer.<name>`, e.g. `integer.month`.
module AnswerCalls
  TRACE = File.expand_path('answer_trace.rb', __dir__)

  def self.names(task_dir)
    answer = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
    Tempfile.create('answer-calls') do |log|
      system({ 'CANDIDATE_IMPLEMENTATION' => answer, 'ANSWER_CALLS_LOG' => log.path },
             RbConfig.ruby, '-r', TRACE, 'behaviour_test.rb', '--seed', '1',
             chdir: task_dir, out: File::NULL, err: File::NULL)
      File.read(log.path).split.map(&:to_sym)
    end
  end
end
