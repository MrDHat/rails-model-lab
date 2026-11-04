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

  def send_link
    member = Member.find_by(email: params[:email].to_s.strip.downcase)
    SessionMailer.sign_in_link(member).deliver_now if member
    redirect_to new_session_path, notice: "Check your email"
  end

  def link
    member = Member.find_by_sign_in_token(params[:token].to_s)
    if member
      member.update!(link_signed_in_at: Time.current)
      session[:member_id] = member.id
      redirect_to tools_path, notice: "Signed in as #{member.name}"
    else
      redirect_to new_session_path, alert: "That link has expired"
    end
  end

  def destroy
    reset_session
    redirect_to new_session_path
  end
end
