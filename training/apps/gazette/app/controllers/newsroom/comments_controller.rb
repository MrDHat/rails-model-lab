module Newsroom
  class CommentsController < BaseController
    before_action :set_comment, only: %i[update destroy]

    def index
      status = Comment.statuses.key?(params[:status]) ? params[:status] : "pending"
      @status = status
      @comments = Comment.where(status: status).includes(:article, :reader).oldest_first.limit(100)
    end

    def update
      @comment.update!(status: params.expect(:status))
      redirect_to newsroom_comments_path, notice: "Comment #{@comment.status}."
    end

    # For spam: removes the comment outright instead of keeping it as rejected.
    def destroy
      @comment.destroy!
      redirect_to newsroom_comments_path, notice: "Comment deleted."
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end
