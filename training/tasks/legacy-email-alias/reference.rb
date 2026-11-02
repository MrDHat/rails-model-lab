class Customer < ActiveRecord::Base
  alias_attribute :email, :emailaddr
end
