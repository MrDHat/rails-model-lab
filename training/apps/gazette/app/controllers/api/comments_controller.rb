module Api
  class CommentsController < BaseController
    before_action :set_article

    # Approved comments, plus the reader's own ones still waiting.
    def index
      comments = @article.comments.approved.or(@article.comments.pending.where(reader: current_reader))
        .includes(:reader).oldest_first
      render json: comments.map(&:as_api)
    end

    def create
      comment = current_reader.comments.create!(article: @article, body: params.expect(comment: [:body])[:body])
      render json: comment.as_api, status: :created
    end

    private

    def set_article
      @article = Article.live.find_by!(slug: params[:article_id])
    end
  end
end
