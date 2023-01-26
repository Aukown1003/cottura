class Public::UsersController < ApplicationController
  before_action :user_check, only: [:edit, :update]
  
  def show
    @user = User.find(params[:id])
    @recipes = Recipe.includes(:user).where(users: {id: @user.id})
                                    .where(recipes: { is_open: true }).page(params[:page])
    @favorited_recipes = @user.favorited_recipes.page(params[:page])

    if admin_signed_in? || user_signed_in?
      if current_admin.present? || current_user.id == User.find(params[:id]).id
        @recipes = @user.recipes.page(params[:page])
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user.id), notice: 'ユーザー情報を編集しました。'
    else
      @user.reload
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
    if current_admin.present?
      return
    elsif user.id != current_user.id || user.email == 'guest@example.com'
      redirect_to root_path, alert: 'ゲストユーザーや他の会員の情報の更新はできません。'
    end
  end

end
