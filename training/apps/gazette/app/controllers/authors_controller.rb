class AuthorsController < ApplicationController
  def show
    @author = Author.find(params[:id])
    @articles = @author.published_articles.includes(:section).limit(30)
  end
end
