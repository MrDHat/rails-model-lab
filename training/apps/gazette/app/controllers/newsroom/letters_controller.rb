module Newsroom
  class LettersController < BaseController
    def index
      @letters = Letter.newest_first.limit(100)
      @letters = @letters.where(status: params[:status]) if Letter.statuses.key?(params[:status])
    end

    def show
      @letter = Letter.find(params[:id])
    end

    def update
      letter = Letter.find(params[:id])
      letter.update!(status: params.expect(:status))
      redirect_to newsroom_letters_path, notice: "Letter #{letter.status}."
    end
  end
end
