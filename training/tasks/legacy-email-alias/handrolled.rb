class Customer < ActiveRecord::Base
  def email
    emailaddr
  end

  def email=(value)
    self.emailaddr = value
  end
end
