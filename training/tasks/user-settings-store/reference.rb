class User < ActiveRecord::Base
  store_accessor :settings, :theme, :digest
end
