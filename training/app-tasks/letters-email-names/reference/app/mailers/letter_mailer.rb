class LetterMailer < ApplicationMailer
  LETTERS_DESK = "letters@gazette.example"
  LETTERS_DESK_NAME = "Harbour Gazette letters desk"

  # To the letters desk, who reply to the writer from their mail client.
  def received(letter)
    @letter = letter
    mail to: LETTERS_DESK, reply_to: email_address_with_name(letter.email, letter.name),
         subject: "Letter: #{letter.subject}"
  end

  # To the writer.
  def acknowledgement(letter)
    @letter = letter
    mail to: email_address_with_name(letter.email, letter.name),
         from: email_address_with_name(LETTERS_DESK, LETTERS_DESK_NAME),
         subject: "We've received your letter"
  end
end
