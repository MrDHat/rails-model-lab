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
    Category.find(params[:id]).destroy
    redirect_to categories_path, notice: "Category deleted"
  end
end
