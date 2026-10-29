# frozen_string_literal: true

# GPUStack's upstream environment loader reads the base but not its optional
# key. Keep this provider-only configuration outside the model's command jail.
require "miniswen"
RubyLLM.configure do |config|
  config.gpustack_api_key = ENV.fetch("GPUSTACK_API_KEY")
  config.max_retries = 0
  config.request_timeout = 1560
end
