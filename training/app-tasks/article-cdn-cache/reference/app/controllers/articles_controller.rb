class ArticlesController < ApplicationController
  def show
    @article = find_article
    @article.record_view! unless current_editor
    @related = @article.related
    @comments = @article.comments.approved.oldest_first.includes(:reader)

    return if current_editor

    expires_in 5.minutes, public: true
    fresh_when @article, public: true
  end

  private

  # Editors can preview stories that aren't live yet.
  def find_article
    scope = current_editor ? Article.all : Article.live
    scope.includes(:section, :authors, :tags, :corrections).find_by!(slug: params[:id])
  end
end
