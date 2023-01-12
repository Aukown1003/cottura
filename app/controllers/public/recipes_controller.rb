class Public::RecipesController < ApplicationController
  def new
    @recipe = Recipe.new
  end

  def index
    # @recipes = Recipe.all
    @recipes = Recipe.includes(:user)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def create
    ActiveRecord::Base.transaction do
      @recipe = current_user.recipes.new(recipe_params)
      if @recipe.save
        redirect_to root_path, notice: "投稿しました"
      else
        render 'new'
      end
    end
  end

  def edit
  end
  
  def destroy
  end

  private
  def recipe_params
      params.require(:recipe).permit(
        :user_id,
        :title,
        :content,
        :total_time,
        :is_open,
        :image,
        recipe_ingredients_attributes: [:id, :name, :quantity, :unit_id, :_destroy],
        recipe_steps_attributes: [:id, :content, :image, :_destroy]
        )
  end

end
