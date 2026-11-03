class Shirt < ActiveRecord::Base
  enum :size, %i[small medium large]
end
