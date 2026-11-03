# For app-task API checks: the methods the answer's changed files called
# while the hidden behaviour tests ran (see bin/grade-app).
module AnswerCalls
  def self.names = File.read(ENV.fetch("ANSWER_CALLS_LOG")).split.map(&:to_sym)
end
