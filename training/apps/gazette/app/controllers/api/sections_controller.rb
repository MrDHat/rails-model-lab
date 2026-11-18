module Api
  class SectionsController < BaseController
    def index
      render json: Section.order(:name).map { { slug: _1.slug, name: _1.name, description: _1.description } }
    end
  end
end
