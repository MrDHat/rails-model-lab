class TagsController < ApplicationController
  def show
    @tag = Tag.find_by!(name: params[:id])
    @articles = @tag.articles.live.newest_first.includes(:section, :authors).limit(30)
  end
end
