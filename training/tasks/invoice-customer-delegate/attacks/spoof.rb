# Expected credit 0.1: manual readers plus a delegate that never runs.
class Client < ActiveRecord::Base
end

class Bill < ActiveRecord::Base
  belongs_to :client, optional: true

  def client_name = client&.name
  def client_email = client&.email
end

if false
  delegate
end
