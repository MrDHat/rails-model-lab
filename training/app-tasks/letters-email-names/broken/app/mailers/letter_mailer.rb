class LetterMailer < ApplicationMailer
  LETTERS_DESK = "letters@gazette.example"
  LETTERS_DESK_NAME = "Harbour Gazette letters desk"

  # To the letters desk, who reply to the writer from their mail client.
  def received(letter)
    @letter = letter
    mail to: LETTERS_DESK, reply_to: "#{letter.name} <#{letter.email}>", subject: "Letter: #{letter.subject}"
  end

  # To the writer.
  def acknowledgement(letter)
    @letter = letter
    mail to: "#{letter.name} <#{letter.email}>", from: "#{LETTERS_DESK_NAME} <#{LETTERS_DESK}>",
         subject: "We've received your letter"
  end
end
