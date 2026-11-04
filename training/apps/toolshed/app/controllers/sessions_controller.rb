class SessionsController < ApplicationController
  def new; end

  def create
    member = Member.find_by(email: params[:email].to_s.strip.downcase)
    if member
      session[:member_id] = member.id
      redirect_to tools_path, notice: "Signed in as #{member.name}"
    else
      flash.now[:alert] = "No member with that email"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to new_session_path
  end
end
