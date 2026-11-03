class ApplicationController < ActionController::Base
  before_action :set_current_member

  private

  def set_current_member
    Current.member = Member.find_by(id: session[:member_id])
  end

  def require_member
    redirect_to new_session_path, alert: "Sign in first" unless Current.member
  end
end
