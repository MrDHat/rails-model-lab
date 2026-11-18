module Newsroom
  class BaseController < ApplicationController
    layout "newsroom"

    before_action :require_editor

    rescue_from Article::InvalidTransition do |error|
      redirect_back fallback_location: newsroom_root_path, alert: error.message
    end

    private

    def require_editor
      redirect_to new_newsroom_session_path unless current_editor
    end

    def require_chief
      redirect_to newsroom_root_path, alert: "Only the chief editor can do that." unless current_editor.chief?
    end
  end
end
