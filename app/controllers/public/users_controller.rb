class Public::UsersController < ApplicationController
  before_action :user_check, only: %i[edit update destroy]
  
  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    redirect_to user_path(current_user.id)
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
