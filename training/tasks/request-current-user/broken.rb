class Current
  class << self
    attr_accessor :user
  end

  def self.reset
    self.user = nil
  end
end

class Note < ActiveRecord::Base
  before_create { self.author ||= Current.user }
end
