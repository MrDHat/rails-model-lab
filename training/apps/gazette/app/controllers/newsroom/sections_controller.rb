module Newsroom
  class SectionsController < BaseController
    before_action :set_section, only: %i[edit update]

    def index
      @sections = Section.order(:name)
    end

    def edit
    end

    def update
      if @section.update(params.expect(section: %i[name description]))
        redirect_to newsroom_sections_path, notice: "Section saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_section
      @section = Section.find_by!(slug: params[:id])
    end
  end
end
