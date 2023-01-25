class Public::UsersController < ApplicationController
  before_action :user_check, only: [:edit, :update, :destroy]
  
  def show
    # binding.pry
    # user = User.includes(:favorited_recipes, :recipes).where(recipes: { is_open: true }).find(params[:id])
    @user = User.includes(:favorited_recipes, :recipes).find(params[:id])
    
    # if admin_signed_in? || user_signed_in?
    #   if current_admin.present? || current_user.id = User.find(params[:id]).id
    #     @user = User.includes(:favorited_recipes, :recipes).find(params[:id])
    #   end
    # end
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
  
  def withdrawal
    @user = current_user
    @user.update(is_active: false)
    reset_session
    redirect_to root_path, notice: '退会が完了しました。'
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
