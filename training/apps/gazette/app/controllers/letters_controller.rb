class LettersController < ApplicationController
  def new
    @letter = Letter.new
  end

  def create
    @letter = Letter.new(params.expect(letter: %i[name email town subject body]))
    if @letter.save
      redirect_to letters_thanks_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thanks
  end
end
