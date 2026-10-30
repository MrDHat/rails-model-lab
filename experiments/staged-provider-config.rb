# frozen_string_literal: true

# Preserve task-selected upstream agents. Only private provider transport changes.
require "miniswen"
require_relative "installed-modal-transport"
raise "Private loopback provider required" unless ENV.fetch("GPUSTACK_API_BASE").match?(%r{\Ahttp://127\.0\.0\.1:\d+/v1\z})
RubyLLM.configure do |config|
  config.gpustack_api_key = ENV.fetch("MODAL_BRIDGE_TOKEN")
  config.max_retries = 0
  config.request_timeout = 1560
end
