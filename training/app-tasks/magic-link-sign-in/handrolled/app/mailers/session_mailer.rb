class SessionMailer < ApplicationMailer
  def sign_in_link(member)
    @member = member
    @url = session_link_url(token: member.sign_in_token)
    mail to: member.email, subject: "Your Toolshed sign-in link"
  end
end
