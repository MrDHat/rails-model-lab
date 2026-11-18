class BriefingMailer < ApplicationMailer
  def morning(reader, articles)
    @reader = reader
    @articles = articles
    mail to: reader.email, subject: "Your Harbour Gazette briefing for #{Time.current.to_date.to_fs(:long)}"
  end
end
