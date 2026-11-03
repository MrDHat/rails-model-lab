class Client < ActiveRecord::Base
end

class Bill < ActiveRecord::Base
  belongs_to :client, optional: true

  def client_name = client.name
  def client_email = client.email
end
