class LetterMailer < ApplicationMailer
  LETTERS_DESK = "letters@gazette.example"
  LETTERS_DESK_NAME = "Harbour Gazette letters desk"

  # To the letters desk, who reply to the writer from their mail client.
  def received(letter)
    @letter = letter
    mail to: LETTERS_DESK, reply_to: named(letter.email, letter.name), subject: "Letter: #{letter.subject}"
  end

  # To the writer.
  def acknowledgement(letter)
    @letter = letter
    mail to: named(letter.email, letter.name), from: named(LETTERS_DESK, LETTERS_DESK_NAME),
         subject: "We've received your letter"
  end

  private

  # "Name" <address>, with quotes and backslashes in the name escaped.
  def named(address, name)
    %("#{name.gsub(/(["\\])/) { "\\#{_1}" }}" <#{address}>)
  end
end
