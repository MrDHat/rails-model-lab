module Api
  class ReadersController < BaseController
    skip_before_action :authenticate_reader, only: :create

    # Sign-up. The app keeps the returned token.
    def create
      reader = Reader.create!(params.expect(reader: %i[email display_name briefing]))
      render json: reader.as_api.merge(api_token: reader.api_token), status: :created
    end

    def show
      render json: current_reader.as_api
    end

    def update
      current_reader.update!(params.expect(reader: %i[display_name briefing]))
      render json: current_reader.as_api
    end

    # Readers can delete their account, and everything they wrote, from the app.
    def destroy
      current_reader.destroy!
      head :no_content
    end
  end
end
