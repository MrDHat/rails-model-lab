require_relative "boot"
require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "rails/test_unit/railtie"
Bundler.require(*Rails.groups)
module ExpenseApp
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
    config.secret_key_base = "development-evaluation-only-not-a-production-secret"
  end
end
