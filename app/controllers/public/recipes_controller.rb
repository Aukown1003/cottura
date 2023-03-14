class Public::RecipesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_toppage
  before_action :authenticate_user!, only: [:new, :create]
  before_action :user_check, only: [:edit, :update, :destroy]
  before_action :gest_user_request_check, only: [:create, :update]
  include ApplicationHelper
  
  def new
    @recipe = Recipe.new
    @genres = Genre.all
    @categories = Category.all
  end

  def index
    recipes = Recipe.with_reviews.by_open.ordered_by_updated_time
    recipes = recipes.by_category(session[:category_id]) if session[:category_id].present? #レシピを絞り込みカテゴリで選択
    recipes = recipes.by_time(session[:search_time].to_i) if session[:search_time].present? #レシピを絞り込み時間で選択
    recipes = Recipe.search_by_keyword(params[:search], recipes) if params[:search].present? #レシピを検索ワードで選択
    @categories = Category.by_id(session[:category_id]) if session[:category_id].present?
    @genres = Genre.with_category
    @recipes = Kaminari.paginate_array(recipes).page(params[:page])
  end

  def show
    @recipe = Recipe.with_recipe_detail_and_review.find(params[:id])
    @review = Review.new
  end

  def create
    ActiveRecord::Base.transaction do
      @recipe = current_user.recipes.new(recipe_params)
      if @recipe.save
        redirect_to user_path(current_user.id), notice: "レシピを投稿しました"
      else
        @recipe.image = nil
        @genres = Genre.all
        @categories = Category.all
        render :new
      end
    end
  end

  def edit
    @recipe = Recipe.find(params[:id])
    @genres = Genre.all
    @categories = Category.by_genre(@recipe.category.genre.id)
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update(recipe_params)
      redirect_to user_path(@recipe.user_id), notice: "レシピを編集しました"
    else
      @recipe.reload
      @genres = Genre.all
      @categories = Category.by_genre(@recipe.category.genre.id)
      flash.now[:alert] = "編集に失敗しました"
      render :edit
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy!
    redirect_to user_path(@recipe.user_id), notice: "レシピを削除しました"
  end
  
  # 投稿編集時のカテゴリーの絞り込み処理
  def search_category
    if params[:genre_id].present?
      @category = Category.where(genre_id: params[:genre_id])
    end
  end
  
  # 一覧でのカテゴリー、時間での絞り込み
  def select_time_or_category
    session[:search_time] = params[:search_time] if params[:search_time].present?
    Recipe.add_category_id_to_session(params[:category_id], session) if params[:category_id].present?
    redirect_to recipes_path
  end

  # 一覧での絞り込みの削除
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

  # 一覧での絞り込みの全件削除
  def category_id_all_delete
    session[:category_id] = nil
    session[:search_time] = nil
    redirect_to recipes_path
  end

  # 詳細でのレシピ材料の分量再計算
  def recalculation
    return redirect_to request.referer, alert: '値を入力してください' if params[:recipe].values[0].empty?
    return redirect_to request.referer, alert: '2つ以上の値で再計算は行なえません' if params[:recipe].keys.size > 1
    get_recipe_id = params.dig(:recipe).keys.first
    get_quantity = params.dig(:recipe).values.first
    session[:recalculation] = Recipe.calculate_ratio(get_recipe_id, get_quantity)
    redirect_to request.referer
  end

  protected
  
  def redirect_to_toppage
    redirect_to root_path, alert: 'レシピが見つかりませんでした'
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
    recipe = Recipe.with_user.find(params[:id])
    return redirect_to root_path, alert: '未ログイン時、レシピの更新、削除はできません。' unless signed_in?
    return redirect_to root_path, alert: '他の会員のレシピの更新、削除はできません。' unless authorized_user?(recipe.user)
  end

  def gest_user_request_check
    return if admin_signed_in?
    if guest_user? && params[:recipe][:is_open] == "true"
      redirect_to new_recipe_path, alert: 'ゲストユーザーはレシピを公開することは出来ません'
    end
  end

end
