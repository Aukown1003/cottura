class Public::RecipesController < ApplicationController
  def new
    @recipe = Recipe.new
  end

  def index
  end

  def show
    
  end

  def edit
  end
  
  private
  def person_params
      params.require(:recipe).permit(
        :user_id,
        :title,
        :content,
        :total_time,
        :is_open,
        recipe_ingredients_attributes: [:id, :content, :quantity, :_destroy],
        recipe_steps_attributes: [:id, :direction, :image, :_destroy]
        )
  end
  
end
