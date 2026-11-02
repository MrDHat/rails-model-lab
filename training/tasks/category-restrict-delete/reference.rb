class Category < ActiveRecord::Base
  has_many :products, dependent: :restrict_with_error
end

class Product < ActiveRecord::Base
  belongs_to :category
end
