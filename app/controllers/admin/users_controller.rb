class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(admin_user_params)
      redirect_to request.referer, notice: 'ユーザーの情報を編集しました'
    else
      redirect_to request.referer, alert: '編集に失敗しました'
      
  end

  private
  def admin_user_params
    params.require(:user).permit(:is_active)
  end
end
