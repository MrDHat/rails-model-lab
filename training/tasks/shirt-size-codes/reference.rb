class Shirt < ActiveRecord::Base
  enum :size, { small: 's', medium: 'm', large: 'l' }
end
