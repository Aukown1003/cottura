class Admin::CategoriesController < ApplicationController
  before_action :authenticate_admin!
  def create
    @category = Category.new(params_category)
    if @category.save
      redirect_to admin_genres_path, notice: 'カテゴリーを作成しました'
    else
      redirect_to admin_genres_path, alert: 'カテゴリーの作成に失敗しました'
    end
  end

  def edit
    @category = Category.find(params[:id])
    @genres = Genre.all
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(params_category)
      redirect_to admin_genres_path, notice: 'カテゴリーを変更しました'
    else
      redirect_to edit_admin_category_path(@category.id), alert: 'カテゴリーの変更に失敗しました'
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy!
    redirect_to admin_genres_path, notice: 'カテゴリーを削除しました'
  end

  private
  def params_category
    params.require(:category).permit(:genre_id, :name)
  end
end
