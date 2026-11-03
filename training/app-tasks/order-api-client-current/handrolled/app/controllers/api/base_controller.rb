module Api
  class BaseController < ActionController::API
    before_action :authenticate_client
    around_action :remember_client

    private

    attr_reader :current_client

    def remember_client
      Thread.current[:api_client] = current_client
      yield
    ensure
      Thread.current[:api_client] = nil
    end

    def authenticate_client
      @current_client = ApiClient.find_by(token: params[:api_key].to_s)
      head :unauthorized unless current_client
    end
  end
end
