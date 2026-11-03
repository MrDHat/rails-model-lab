# Loaded with `ruby -r` before a behaviour test. Records the name of every
# method that the answer file calls while the test runs, skipping methods the
# answer defines itself, and writes them to ANSWER_CALLS_LOG on exit.
answer = File.expand_path(ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb'))
names = {}
trace = TracePoint.new(:call, :c_call) do |tp|
  # A Ruby method has already pushed its own frame; a C method has not.
  caller = caller_locations(tp.event == :call ? 2 : 1, 1)&.first
  next unless caller&.path == answer
  next if tp.event == :call && tp.path == answer
  names[tp.self.is_a?(Integer) ? :"integer.#{tp.method_id}" : tp.method_id] = true
end
trace.enable
# at_exit handlers run last-registered first, so this runs after Minitest's.
at_exit { File.write(ENV.fetch('ANSWER_CALLS_LOG'), names.keys.join("\n")) }
