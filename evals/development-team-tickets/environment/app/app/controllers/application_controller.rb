class ApplicationController < ActionController::API
  before_action :require_current_team

  private

  # Development identity fixture: the trusted gateway supplies this header.
  # Authentication itself is outside this app's evaluation scope.
  def require_current_team
    @current_team = Team.find_by(id: request.headers["X-Team-ID"])
    render json: { error: "Team required" }, status: :unauthorized unless @current_team
  end

  attr_reader :current_team
end
