module Newsroom
  class SettingsController < BaseController
    before_action :require_chief

    def edit
    end

    def update
      values = params.expect(settings: %i[comments_open briefing_size front_page_order])
      Setting.transaction do
        Setting[:comments_open] = values[:comments_open] == "1" if values.key?(:comments_open)
        Setting[:briefing_size] = values[:briefing_size].to_i.clamp(1, 10) if values.key?(:briefing_size)
        if values.key?(:front_page_order)
          Setting[:front_page_order] = values[:front_page_order].to_s.split(",").map(&:strip).compact_blank
        end
      end
      redirect_to edit_newsroom_settings_path, notice: "Settings saved."
    end
  end
end
