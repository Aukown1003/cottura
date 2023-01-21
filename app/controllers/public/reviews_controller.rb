class Public::ReviewsController < ApplicationController
  before_action :authenticate_user!

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
    review.destroy
    redirect_to request.referer, notice: 'レビューを削除しました。'
  end

  private
  def review_params
    params.require(:review).permit(:user_id ,:recipe_id, :score, :content)
  end

end
