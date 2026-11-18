module Api
  class ArticlesController < BaseController
    LIMIT = 50

    # The app syncs with ?updated_since=<iso8601>, oldest change first, and
    # asks again from the last updated_at it got until the list comes back
    # short.
    def index
      articles = Article.live.includes(:section, :authors, :tags)
      articles = articles.joins(:section).where(sections: { slug: params[:section] }) if params[:section].present?
      articles = articles.tagged(params[:tag]) if params[:tag].present?
      articles =
        if params[:updated_since].present?
          articles.where(updated_at: parse_time(params[:updated_since])..).order(:updated_at, :id)
        else
          articles.newest_first
        end

      render json: articles.limit(LIMIT).map(&:as_api)
    end

    def show
      article = Article.live.find_by!(slug: params[:id])
      render json: article.as_api.merge(body: article.body, corrections: article.corrections.map(&:body))
    end

    private

    def parse_time(value)
      Time.zone.iso8601(value.to_s)
    rescue ArgumentError
      raise ActionController::BadRequest, "invalid time #{value.inspect}"
    end
  end
end
