# Expected credit 0.0: declares the accessors but always reads digest as nil.
class User < ActiveRecord::Base
  store_accessor :settings, :theme, :digest
  def digest = nil
end
