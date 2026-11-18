class WireImportJob < ApplicationJob
  def perform(payload)
    WireFeed.import(payload)
  end
end
