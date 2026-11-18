class SectionsController < ApplicationController
  PER_PAGE = 20
  FEED_SIZE = 20

  def show
    @section = Section.find_by!(slug: params[:id])

    respond_to do |format|
      format.html do
        @articles = @section.articles.live.newest_first.includes(:authors)
          .offset((page_number - 1) * PER_PAGE).limit(PER_PAGE)
      end
      format.atom { @articles = @section.articles.where.not(status: :spiked).newest_first.limit(FEED_SIZE) }
    end
  end
end
