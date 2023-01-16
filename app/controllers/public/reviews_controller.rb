class Public::ReviewsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @review = current_user.reviews.new(review_params)
    # binding.pry
    if params[:review][:score].empty? || params[:review][:content].empty?
      @recipe = Recipe.find_by(id: params[:review][:recipe_id])
      flash.now[:alert] = 'レビューの投稿に失敗しました'
      render template: "public/recipes/show"
    else
      @review.save
      redirect_to root_path
    end
    
    # if @review.save
    #   redirect_to root_path
    # else
    #   @recipe = Recipe.find_by(id: params[:review][:recipe_id])
    #   flash.now[:danger] = '失敗しました'
    #   render template: "public/recipes/show"
    # end
  end
  
  def destroy
    
  end
  
  private
  def review_params
    params.require(:review).permit(:user_id ,:recipe_id, :score, :content)
  end
  
end
