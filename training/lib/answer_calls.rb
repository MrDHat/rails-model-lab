require 'prism'

# Method names the answer under test calls, read from its syntax tree so
# comments and strings don't count. For API checks Rails can't answer by
# reflection, such as query methods. Calls on an integer literal are recorded
# as "integer.<name>", so `1.month` is told apart from `date.month`.
module AnswerCalls
  def self.names(task_dir)
    file = File.expand_path(ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb'), task_dir)
    names = []
    nodes = [Prism.parse_file(file).value]
    while (node = nodes.shift)
      if node.is_a?(Prism::CallNode)
        names << (node.receiver.is_a?(Prism::IntegerNode) ? :"integer.#{node.name}" : node.name)
      end
      nodes.concat(node.compact_child_nodes)
    end
    names
  end
end
