module Newsroom
  class SessionsController < BaseController
    skip_before_action :require_editor, only: %i[new create]

    def new
    end

    def create
      if (editor = Editor.authenticate(params[:email], params[:access_code]))
        reset_session
        session[:editor_id] = editor.id
        redirect_to newsroom_root_path
      else
        flash.now[:alert] = "Wrong email or access code."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      reset_session
      redirect_to new_newsroom_session_path
    end
  end
end
