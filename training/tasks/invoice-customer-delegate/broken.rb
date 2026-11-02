class Client < ActiveRecord::Base
end

class Bill < ActiveRecord::Base
  belongs_to :client, optional: true
  delegate :name, :email, to: :client, prefix: true
end
