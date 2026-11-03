class Category < ActiveRecord::Base
  has_many :products
  before_destroy :ensure_empty

  private

  def ensure_empty
    return unless products.exists?
    errors.add(:base, 'Cannot delete a category that has products')
    throw :abort
  end
end

class Product < ActiveRecord::Base
  belongs_to :category
end
