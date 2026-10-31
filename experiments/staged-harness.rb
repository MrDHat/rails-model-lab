# frozen_string_literal: true

# Load transport through Ruby, not an unsupported lemans CLI flag.
require_relative "staged-provider-config"
require "lemans/cli"
Lemans::CLI.start(ARGV)
