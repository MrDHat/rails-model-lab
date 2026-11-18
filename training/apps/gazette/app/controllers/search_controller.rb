class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @articles = @query.present? ? Article.live.search(@query).newest_first.includes(:section).limit(30) : Article.none
  end
end
