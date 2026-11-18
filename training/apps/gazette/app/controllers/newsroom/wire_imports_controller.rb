module Newsroom
  # Agency copy normally arrives by the agency's push; editors can also paste
  # a delivery here.
  class WireImportsController < BaseController
    def index
      @imports = WireImport.newest_first.limit(30)
    end

    def create
      payload = params.expect(:payload)
      JSON.parse(payload)
      WireImportJob.perform_later(payload)
      redirect_to newsroom_wire_imports_path, notice: "Import queued."
    rescue JSON::ParserError
      redirect_to newsroom_wire_imports_path, alert: "That isn't a wire delivery."
    end
  end
end
