require "test_helper"

class CheckoutFormObjectApiTest < ActiveSupport::TestCase
  test "the request is checked by an Active Model object" do
    Rails.application.eager_load!
    app = Rails.root.join("app").to_s
    models = ObjectSpace.each_object(Class).select do |klass|
      klass.include?(ActiveModel::Validations) && !(klass <= ActiveRecord::Base) && klass.name &&
        Object.const_source_location(klass.name)&.first.to_s.start_with?(app)
    end
    assert models.any?, "no Active Model class in app/"
  end
end
