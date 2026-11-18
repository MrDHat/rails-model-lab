module Newsroom
  class SettingsController < BaseController
    before_action :require_chief

    def edit
    end

    def update
      values = params.expect(settings: %i[comments_open briefing_size])
      Setting.transaction do
        Setting[:comments_open] = values[:comments_open] == "1" if values.key?(:comments_open)
        Setting[:briefing_size] = values[:briefing_size].to_i.clamp(1, 10) if values.key?(:briefing_size)
      end
      redirect_to edit_newsroom_settings_path, notice: "Settings saved."
    end
  end
end
