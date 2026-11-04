module Api
  class BaseController < ActionController::API
    before_action :authenticate_client

    private

    attr_reader :current_client

    def authenticate_client
      @current_client = ApiClient.find_by(token: params[:api_key].to_s)
      Thread.current[:api_client] = current_client
      head :unauthorized unless current_client
    end
  end
end
