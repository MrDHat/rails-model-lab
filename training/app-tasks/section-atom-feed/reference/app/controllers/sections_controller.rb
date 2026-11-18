class SectionsController < ApplicationController
  PER_PAGE = 20
  FEED_SIZE = 20

  def show
    @section = Section.find_by!(slug: params[:id])
    stories = @section.articles.live.newest_first.includes(:authors)

    respond_to do |format|
      format.html { @articles = stories.offset((page_number - 1) * PER_PAGE).limit(PER_PAGE) }
      format.atom { @articles = stories.limit(FEED_SIZE) }
    end
  end
end
