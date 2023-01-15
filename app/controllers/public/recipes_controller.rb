class Public::RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index,:show]
  before_action :user_check, only: [:edit, :update, :destroy]

  def search
    # binding.pry
    # if session[:category_id].present?
    #   data = session[:category_id]
    # else
    #   data = []
    # end
    # add_data = params[:category_id].reject(&:empty?)
    # add_data.each do |f|
    #   data << f
    # end

    add_data = params[:category_id]
    if session[:category_id].present?
      data = session[:category_id]
      data << add_data
    else
      data = [] << add_data
    end

    data.uniq!
    session[:category_id] = data
    redirect_to recipes_path
  end

  def new
    @recipe = Recipe.new
  end

  def index
    # 後でis_open falseを除くように
    @recipes = Recipe.all.includes(:recipe_steps).includes(:recipe_ingredients)
    if session[:category_id].present?
      @recipes = @recipes.where(category: session[:category_id])
      @categories = Category.where(id: session[:category_id])
    end
    @genres = Genre.all
    # byebug
    if params[:search].present?
      keyword = params[:search].split(/ |　/).uniq.compact
      @recipes.each do |recipe|
       recipe.assign_attributes(payload: (recipe.recipe_steps.pluck(:content).join + recipe.recipe_ingredients.pluck(:name).join + recipe.title))
      end
      @recipes = @recipes.select do |o|
        result = keyword.map{ |k| o.payload.include?(k) }
        result.compact.uniq.size == 1 && result.compact.uniq.first == true
      end
    end
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
    @recipe = Recipe.find(params[:id])
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.recipe_ingredients == [] || @recipe.recipe_steps == []
      redirect_to request.referer, alert: "材料または作り方が未入力です。"
      return
    end
    if @recipe.update(recipe_params)
      redirect_to root_path
    else
      flash.now[:alert] = "編集に失敗しました"
      render :edit
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    redirect_to recipes_path
  end

  def category_id_delete
    data = session[:category_id]
    delete_data = params[:destroy_category_id]
    data.delete(delete_data)
    # delete_data = params[:destroy_category_id].reject(&:empty?)
    # delete_data.each do |f|
    #   category_id_data.delete(f)
    # end
    session[:category_id] = data
    redirect_to recipes_path
  end

  def category_id_all_delete
    session[:category_id] = nil
    redirect_to recipes_path
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
    c = (BigDecimal(get_quantity.to_s) / a).to_f
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
        :category_id,
        :is_open,
        :image,
        recipe_ingredients_attributes: [:id, :name, :quantity, :unit_id, :_destroy],
        recipe_steps_attributes: [:id, :content, :image, :_destroy],
        tags_attributes: [:id, :name, :_destroy],
        )
  end

  def user_check
    user_id = Recipe.find(params[:id]).user_id
    if user_id =! current_user.id
      redirect_to root_path, alert: '他の会員のレシピの更新、削除はできません。'
    end
  end

end
