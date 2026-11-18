class LetterMailer < ApplicationMailer
  LETTERS_DESK = "letters@gazette.example"

  # To the letters desk, who reply to the writer from their mail client.
  def received(letter)
    @letter = letter
    mail to: LETTERS_DESK, reply_to: letter.email, subject: "Letter: #{letter.subject}"
  end

  # To the writer.
  def acknowledgement(letter)
    @letter = letter
    mail to: letter.email, from: LETTERS_DESK, subject: "We've received your letter"
  end
end
