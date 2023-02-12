class Public::RecipesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :user_check, only: [:edit, :update, :destroy]
  before_action :gest_user_request_check, only: [:create, :update]
  include ApplicationHelper
  
  def new
    @recipe = Recipe.new
    @genre = Genre.all
    @category = Category.all
  end

  def index
    # @recipes = Recipe.where(is_open: true).includes(:recipe_steps, :recipe_ingredients).order(category_id: :asc)
    # if session[:category_id].present? && session[:search_time].present?
    #   @recipes = @recipes.where(category: session[:category_id]).where(total_time: ..session[:search_time].to_i)
    #   @categories = Category.where(id: session[:category_id])
    # elsif session[:category_id].present?
    #   @recipes = @recipes.where(category: session[:category_id])
    #   @categories = Category.where(id: session[:category_id])
    # elsif session[:search_time].present?
    #   @recipes = @recipes.where(total_time: ..session[:search_time].to_i)
    # end
    # @genres = Genre.all.includes(:categories)

    @recipes = Recipe.with_reviews.by_open.ordered_by_updated_time
    @recipes = @recipes.by_category(session[:category_id]) if session[:category_id].present?
    @recipes = @recipes.by_time(session[:search_time].to_i) if session[:search_time].present?
    @categories = Category.by_id(session[:category_id]) if session[:category_id].present?
    @genres = Genre.with_category

    if params[:search].present?
      # params[:search] => "文字 文字"
      # .split(/ |　/) => ["文字","文字"] スペースで区切って配列に
      # .uniq => 重複を削除
      # .compact => nillが含まれるものを削除
      keyword = params[:search].split(/ |　/).uniq.compact
      # assign_attributesでpayloadにデータを追加
      @recipes.each do |recipe|
        recipe.assign_attributes(payload: (recipe.recipe_steps.pluck(:content).join + recipe.recipe_ingredients.pluck(:name).join + recipe.tags.pluck(:name).join + recipe.title ))
      end
      # レシピを一つづつ見て、payloadにkeywordが含まれているものだけを取得する
      @recipes = @recipes.select do |o|
        result = keyword.map{ |k| o.payload.include?(k) }
        result.compact.uniq.size == 1 && result.compact.uniq.first == true
      end
    end
    @recipes = Kaminari.paginate_array(@recipes).page(params[:page])
  end

  def show
    @recipe = Recipe.with_recipe_detail_and_review.find(params[:id])
    @review = Review.new
    impressionist(@recipe, nil, unique: [:ip_address])
  end

  def create
    ActiveRecord::Base.transaction do
      @recipe = current_user.recipes.new(recipe_params)
      if @recipe.save
        redirect_to user_path(current_user.id), notice: "レシピを投稿しました"
      else
        @recipe.image = nil
        @genre = Genre.all
        @category = Category.all
        render :new
      end
    end
  end

  def edit
    @recipe = Recipe.find(params[:id])
    @genre = Genre.all
    @category = Category.by_genre(@recipe.category.genre.id)
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update(recipe_params)
      redirect_to user_path(@recipe.user_id), notice: "レシピを編集しました"
    else
      @recipe.reload
      @genre = Genre.all
      @category = Category.by_genre(@recipe.category.genre.id)
      flash.now[:alert] = "編集に失敗しました"
      render :edit
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    redirect_to user_path(@recipe.user_id), notice: "レシピを削除しました"
  end

  def search_category
    @category = Category.where(genre_id: params[:genre_id])
    if @category.empty?
      @category = nil
    end
  end

  def search
    if params[:search_time].present?
      time_data = params[:search_time]
      session[:search_time] = time_data
    end
    
    if params[:category_id].present?
      add_data = params[:category_id]
      if session[:category_id].present?
        data = session[:category_id]
        data << add_data
      else
        data = [] << add_data
      end

      data.uniq!
      session[:category_id] = data
    end
    
    redirect_to recipes_path
  end

  def category_id_delete
    if params[:destroy_time_id].present?
      session[:search_time] = nil
    end
    if params[:destroy_category_id].present?
      data = session[:category_id]
      delete_data = params[:destroy_category_id]
      data.delete(delete_data)
      session[:category_id] = data
    end
    redirect_to recipes_path
  end

  def category_id_all_delete
    session[:category_id] = nil
    session[:search_time] = nil
    redirect_to recipes_path
  end

  def recalculation
    arry = {}
    if params[:recipe].keys.size > 1
      redirect_to request.referer, alert: '2つ以上の値で再計算は行なえません'
      return
    end
    params[:recipe].each do |key, value|
      unless value.empty?
        arry.store(key, value)
      end
    end
    get_recipe_id = arry.first[0]
    get_quantity = arry.first[1]
    ingredient_quantity = RecipeIngredient.find(get_recipe_id).quantity
    ratio = (BigDecimal(get_quantity.to_s) / ingredient_quantity).to_f
    session[:recalculation] = ratio
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
  
  # def user_check
  #   user_id = Recipe.find(params[:id]).user_id
  #   unless user_signed_in? || admin_signed_in?
  #     redirect_to root_path, alert: '未ログイン時、レシピの更新、削除はできません。'
  #     return
  #   end
  #   unless admin_signed_in? || user_id == current_user.id
  #     redirect_to root_path, alert: '他の会員のレシピの更新、削除はできません。'
  #   end
  # end
  
  def user_check
    recipe = Recipe.with_user.find(params[:id])
    return redirect_to root_path, alert: '未ログイン時、レシピの更新、削除はできません。' unless signed_in?
    return redirect_to root_path, alert: '他の会員のレシピの更新、削除はできません。' unless authorized_user?(recipe.user)
  end
  
  # def gest_user_request_check
  #   if admin_signed_in?
  #     return
  #   elsif current_user.present? && current_user.email == "guest@example.com" && params[:recipe][:is_open] == "true"
  #     redirect_to new_recipe_path, alert: 'ゲストユーザーはレシピを公開することは出来ません'
  #   end
  # end

  def gest_user_request_check
    return if admin_signed_in?
    if guest_user? && params[:recipe][:is_open] == "true"
      redirect_to new_recipe_path, alert: 'ゲストユーザーはレシピを公開することは出来ません'
    end
  end

end
