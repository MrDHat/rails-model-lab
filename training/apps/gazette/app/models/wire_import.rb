# One delivery from the news agency's wire. See WireFeed.
class WireImport < ApplicationRecord
  scope :newest_first, -> { order(received_at: :desc) }
end
