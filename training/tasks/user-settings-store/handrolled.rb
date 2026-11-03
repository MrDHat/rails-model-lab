class User < ActiveRecord::Base
  %w[theme digest].each do |key|
    define_method(key) { (settings || {})[key] }
    define_method("#{key}=") { |value| self.settings = (settings || {}).merge(key => value) }
  end
end
