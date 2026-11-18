module Newsroom
  class CorrectionsController < BaseController
    def create
      article = Article.find_by!(slug: params[:article_id])
      correction = article.corrections.new(body: params.expect(correction: [:body])[:body], editor: current_editor)
      if correction.save
        redirect_to edit_newsroom_article_path(article), notice: "Correction added."
      else
        redirect_to edit_newsroom_article_path(article), alert: correction.errors.full_messages.first
      end
    end
  end
end
