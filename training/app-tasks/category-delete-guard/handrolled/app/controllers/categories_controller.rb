class CategoriesController < ApplicationController
  def index
    @categories = Category.order(:name)
  end

  def create
    category = Category.new(name: params.dig(:category, :name))
    if category.save
      redirect_to categories_path, notice: "Category added"
    else
      redirect_to categories_path, alert: category.errors.full_messages.to_sentence
    end
  end

  def destroy
    category = Category.find(params[:id])
    if category.destroy
      redirect_to categories_path, notice: "Category deleted"
    else
      redirect_to categories_path, alert: category.errors.full_messages.to_sentence
    end
  end
end
