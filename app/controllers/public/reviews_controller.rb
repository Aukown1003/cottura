class Public::ReviewsController < ApplicationController
  before_action :user_check

  def create
    @review = current_user.reviews.new(review_params)
    if @review.save
      redirect_to recipe_path(params[:review][:recipe_id]), notice: 'レビューを投稿しました。'
    else
      redirect_to recipe_path(params[:review][:recipe_id]), alert: 'レビューの投稿に失敗しました。未入力の項目があります'
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
    if user_signed_in? || admin_signed_in?
      if params[:create] == "create"
        recipe_user = Recipe.find(params[:review][:recipe_id]).user_id
      elsif params[:action] == "destroy"
        recipe_user = Recipe.find(params[:recipe_id]).user_id
      end
      
      if admin_signed_in?
        return
      elsif current_user.email == "guest@example.com"
        redirect_to recipes_path, alert: 'ゲストユーザーはレビューを投稿、削除することは出来ません'
      elsif current_user.id == recipe_user
        redirect_to recipes_path, alert: '自身のレシピにレビューを投稿、削除することは出来ません'
      end
    else
      redirect_to recipes_path, alert: '未ログイン時、レビューを投稿、削除することは出来ません'
    end
    
  end
end
