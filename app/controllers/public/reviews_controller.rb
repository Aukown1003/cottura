class Public::ReviewsController < ApplicationController
  before_action :user_check
  include ApplicationHelper

  def create
    @review = current_user.reviews.new(review_params)
    if @review.save
      redirect_to recipe_path(params[:review][:recipe_id]), notice: 'レビューを投稿しました。'
    else
      redirect_to recipe_path(params[:review][:recipe_id]), alert: 'レビューの投稿に失敗しました。未入力の項目があります。'
    end
  end

  def destroy
    review = Review.find(params[:id])
    if review.destroy
      redirect_to request.referer, notice: 'レビューを削除しました。'
    else
      redirect_to request.referer, alert: 'レビューの削除に失敗しました。'
    end
  end

  private
  
  def review_params
    params.require(:review).permit(:user_id ,:recipe_id, :score, :content)
  end
  
  def user_check
    redirect_to recipes_path, alert: '未ログイン時、レビューを投稿、削除することは出来ません' and return unless user_signed_in?
    redirect_to recipes_path, alert: 'ゲストユーザーはレビューを投稿、削除することは出来ません' and return if guest_user?
    
    recipe = params[:review].present? ? Recipe.find(params[:review][:recipe_id]) : Recipe.find(params[:id])
    redirect_to recipes_path, alert: '自身のレシピにレビューを投稿、削除することは出来ません' if current_user.id == recipe.user_id
  
    return if admin_signed_in?
  end

end
