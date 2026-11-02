class Item < ActiveRecord::Base
  before_update { self.sku = sku_was if sku_changed? }
end
