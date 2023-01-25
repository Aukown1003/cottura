class Public::RecipesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :user_check, only: [:edit, :update, :destroy]
  before_action :gest_user_request_check, only: [:create, :update]

  def new
    @recipe = Recipe.new
    @genre = Genre.all
    @category = Category.all
  end

  def index
    @recipes = Recipe.where(is_open: true).includes(:recipe_steps, :recipe_ingredients)
    if session[:category_id].present? && session[:search_time].present?
      @recipes = @recipes.where(category: session[:category_id]).where(total_time: ..session[:search_time].to_i)
      @categories = Category.where(id: session[:category_id])
    elsif session[:category_id].present?
      @recipes = @recipes.where(category: session[:category_id])
      @categories = Category.where(id: session[:category_id])
    elsif session[:search_time].present?
      @recipes = @recipes.where(total_time: ..session[:search_time].to_i)
    end
    @genres = Genre.all.includes(:categories)

    # 以下検索ロジック
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
    @recipe = Recipe.includes(:recipe_ingredients, :recipe_steps, :tags, :reviews).find(params[:id])
    @review = Review.new
    impressionist(@recipe, nil, unique: [:ip_address])
  end

  def create
    ActiveRecord::Base.transaction do
      @recipe = current_user.recipes.new(recipe_params)
      if @recipe.save
        redirect_to root_path, notice: "レシピを投稿しました"
      else
        @recipe.image = nil
        @genre = Genre.all
        @category = Category.all
        render :new
      end
    end
  end

  def edit
    @recipe = Recipe.includes(:category).find(params[:id])
    @genre = Genre.all
    @category = Category.where(genre_id: @recipe.category.genre.id)
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update(recipe_params)
      redirect_to root_path, notice: "レシピを編集しました"
    else
      @recipe.reload
      @genre = Genre.all
      @category = Category.where(genre_id: @recipe.category.genre.id)
      flash.now[:alert] = "編集に失敗しました"
      render :edit
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    redirect_to recipes_path
  end

  def search_category
    @category = Category.where(genre_id: params[:genre_id])
  end

  def search
    # if session[:category_id].present?
    #   data = session[:category_id]
    # else
    #   data = []
    # end
    # add_data = params[:category_id].reject(&:empty?)
    # add_data.each do |f|
    #   data << f
    # end
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
      # delete_data = params[:destroy_category_id].reject(&:empty?)
      # delete_data.each do |f|
      #   category_id_data.delete(f)
      # end
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
    if params[:recipe].keys[1].present?
      redirect_to request.referer, alert: '２つ以上の値で再計算は行なえません'
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
  #   if admin_signed_in?
  #   elsif user_signed_in?
  #     user_id = Recipe.find(params[:id]).user_id
  #     if user_id =! current_user.id
  #       redirect_to root_path, alert: '他の会員のレシピの更新、削除はできません。'
  #     end
  #   else
  #     redirect_to root_path, alert: '非ログイン時はこの処理を行えません'
  #   end
  # end
  
  def user_check
    user_id = Recipe.find(params[:id]).user_id
    if admin_signed_in?
      return
    elsif user_signed_in?
      if user_id =! current_user.id
        redirect_to root_path, alert: '他の会員のレシピの更新、削除はできません。'
      end
    else
      redirect_to root_path, alert: '未ログイン時、レシピの更新、削除はできません。'
    end
  end
  
  def gest_user_request_check
    if current_user.present? && current_user.email == "guest@example.com" && params[:recipe][:is_open] == "true"
      redirect_to new_recipe_path, alert: 'ゲストユーザーはレシピを公開することは出来ません'
    end
  end

end
