module Newsroom
  # The story list and editor. The desk app (used on phones at events) talks
  # to update with JSON.
  class ArticlesController < BaseController
    before_action :set_article, only: %i[show edit update transition]

    def index
      @articles = Article.includes(:section, :authors).order(updated_at: :desc).limit(100)
      @articles = @articles.where(status: params[:status]) if params[:status].present?
      @articles = @articles.where(section_id: params[:section_id]) if params[:section_id].present?
      @articles = @articles.search(params[:q]) if params[:q].present?
    end

    def show
    end

    def new
      @article = Article.new(section_id: params[:section_id])
      @article.authorships.build(author: current_editor.author) if current_editor.author
    end

    def create
      @article = Article.new(article_params.except(:author_ids))
      Article.transaction do
        @article.save!
        @article.author_ids_in_order = article_params[:author_ids]
      end
      redirect_to edit_newsroom_article_path(@article), notice: "Draft saved."
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    end

    def edit
    end

    def update
      saved = Article.transaction do
        @article.update(article_params.except(:author_ids)).tap do |ok|
          @article.author_ids_in_order = article_params[:author_ids] if ok && article_params.key?(:author_ids)
        end
      end

      respond_to do |format|
        if saved
          format.html { redirect_to edit_newsroom_article_path(@article), notice: "Saved." }
          format.json { render json: @article.as_api.merge(status: @article.status) }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    # Publish, schedule, unpublish or spike.
    def transition
      case params[:event]
      when "publish" then @article.publish!
      when "schedule" then @article.schedule!(Time.zone.parse(params[:publish_at].to_s))
      when "unpublish" then @article.unpublish!
      when "spike" then @article.spike!
      else raise ActionController::BadRequest, "unknown event #{params[:event].inspect}"
      end
      redirect_to edit_newsroom_article_path(@article), notice: "Story is now #{@article.status}."
    end

    private

    def set_article
      @article = Article.find_by!(slug: params[:id])
    end

    def article_params
      @article_params ||= params.expect(article: [:headline, :dek, :body, :section_id, :tag_list, :status,
                                                  :comments_enabled, { author_ids: [] }])
    end
  end
end
