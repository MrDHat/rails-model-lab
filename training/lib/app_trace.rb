# Loaded with `ruby -r` (through RUBYOPT) before an app's test run. Records the
# name of every method called from the files the answer changed or added
# (ANSWER_FILES, one absolute path per line), skipping methods those files
# define, and writes them to ANSWER_CALLS_LOG on exit.
files = File.readlines(ENV.fetch('ANSWER_FILES'), chomp: true).to_h { [_1, true] }
names = {}
trace = TracePoint.new(:call, :c_call) do |tp|
  # A Ruby method has already pushed its own frame; a C method has not.
  caller = caller_locations(tp.event == :call ? 2 : 1, 1)&.first
  next unless caller && files[caller.path]
  next if tp.event == :call && files[tp.path]
  names[tp.self.is_a?(Integer) ? :"integer.#{tp.method_id}" : tp.method_id] = true
end
trace.enable
# Registered first, so it runs after Minitest's at_exit has run the tests.
at_exit { File.write(ENV.fetch('ANSWER_CALLS_LOG'), names.keys.join("\n")) }
