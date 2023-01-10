class Public::RecipesController < ApplicationController
  def new
    @recipe = Recipe.new
  end

  def index
    @recipes = Recipe.all
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def create
    ActiveRecord::Base.transaction do
      recipe = current_user.recipes.new(recipe_params)
      # binding.pry
      recipe.save!
    end
    redirect_to root_path, notice: "投稿しました"
  end

  def edit
  end

  private
  def recipe_params
      params.require(:recipe).permit(
        :user_id,
        :title,
        :content,
        :total_time,
        :is_open,
        recipe_ingredients_attributes: [:id, :name, :quantity, :unit_id, :_destroy],
        recipe_steps_attributes: [:id, :content, :_destroy]
        )
  end

end
