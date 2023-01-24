class Public::UsersController < ApplicationController
  before_action :user_check, only: [:edit, :update, :destroy]
  
  def show
    @user = User.includes(:favorited_recipes, :recipes).find(params[:id])
    @recipes = @user.recipes.page(params[:page])
    @favorited_recipes =@user.favorited_recipes.page(params[:page])
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(current_user.id)
    else
      flash.now[:alert] = "編集に失敗しました"
      render :edit
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :content, :image)
  end
  
  def user_check
    user = User.find(params[:id])
    if user.id =! current_user.id || user.email == 'guest@example.com'
      redirect_to root_path, alert: 'ゲストユーザーや他の会員の、情報の更新、削除はできません。'
    end
  end
  
end
