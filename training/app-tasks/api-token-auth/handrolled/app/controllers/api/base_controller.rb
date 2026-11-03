module Api
  class BaseController < ActionController::API
    before_action :authenticate_client

    private

    attr_reader :current_client

    def authenticate_client
      token = request.authorization.to_s[/\ABearer (.+)\z/, 1] || params[:api_key].to_s
      @current_client = ApiClient.find_by(token: token)
      return if current_client

      response.headers["WWW-Authenticate"] = 'Token realm="Crumb"'
      head :unauthorized
    end
  end
end
