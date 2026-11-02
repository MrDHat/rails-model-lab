class Member < ActiveRecord::Base
  attr_accessor :terms_of_service
  validate :terms_ticked, on: :create

  private

  def terms_ticked
    errors.add(:terms_of_service, :accepted) unless terms_of_service.to_s == '1'
  end
end
