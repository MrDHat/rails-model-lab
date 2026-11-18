class SectionsController < ApplicationController
  PER_PAGE = 20

  def show
    @section = Section.find_by!(slug: params[:id])
    @articles = @section.articles.live.newest_first.includes(:authors)
      .offset((page_number - 1) * PER_PAGE).limit(PER_PAGE)
  end
end
