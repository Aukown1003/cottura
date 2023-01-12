class Public::RecipesController < ApplicationController
  def new
    @recipe = Recipe.new
  end

  def index
    @recipes = Recipe.all
    # @recipes = Recipe.includes(:user)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def create
    ActiveRecord::Base.transaction do
      @recipe = current_user.recipes.new(recipe_params)
      # binding.pry
      if @recipe.recipe_ingredients == [] || @recipe.recipe_steps == []
        redirect_to new_recipe_path, alert: "材料または作り方が未入力です。"
        return
      end
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

  def recalculation

    arry = {}
    params[:recipe].each do |key, value|
      unless value.empty?
        arry.store(key, value)
      end
    end
    get_recipe_id = arry.first[0]
    get_quantity = arry.first[1]
    a = RecipeIngredient.find(get_recipe_id).quantity
    # binding.pry
     c = get_quantity.to_f / a.to_f
    session[:recalculation] = c
    # arry.each do |id, val|
    # end

    redirect_to request.referer
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
