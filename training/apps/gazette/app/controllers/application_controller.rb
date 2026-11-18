class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_editor

  private

  # Editors signed in to the newsroom see drafts and edit links on the site.
  def current_editor
    return unless session[:editor_id]

    @current_editor ||= Editor.find_by(id: session[:editor_id])
  end

  def page_number = [params[:page].to_i, 1].max
end
