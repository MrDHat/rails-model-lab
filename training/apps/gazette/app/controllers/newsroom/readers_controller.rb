module Newsroom
  class ReadersController < BaseController
    before_action :require_chief, only: :destroy

    def index
      @readers = Reader.order(:display_name).limit(100)
      @readers = @readers.search(params[:q]) if params[:q].present?
    end

    def show
      @reader = Reader.find(params[:id])
      @comments = @reader.comments.includes(:article).order(created_at: :desc).limit(50)
    end

    # Account deletion requests that come in by email.
    def destroy
      reader = Reader.find(params[:id])
      reader.destroy!
      redirect_to newsroom_readers_path, notice: "#{reader.display_name}'s account was deleted."
    end
  end
end
