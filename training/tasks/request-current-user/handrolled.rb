class Current
  def self.user = Thread.current[:current_user]
  def self.user=(value)
    Thread.current[:current_user] = value
  end

  def self.reset
    Thread.current[:current_user] = nil
  end
end

class Note < ActiveRecord::Base
  before_create { self.author ||= Current.user }
end
