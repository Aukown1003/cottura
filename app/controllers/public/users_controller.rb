class Public::UsersController < ApplicationController
  before_action :user_check, only: %i[edit update destroy]
  
  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end
  
   def user_check
     unless current_user.id == params[:id]
       redirect_to user_path(id: params[:id])
     end
   end
  
end
