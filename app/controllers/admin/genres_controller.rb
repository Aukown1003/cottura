class Admin::GenresController < ApplicationController
  before_action :authenticate_admin!
  def index
    @genres = Genre.all
    @genre = Genre.new
    if params[:genre_id].present?
      @categories = Category.by_genre(params[:genre_id]).order(id: :ASC)
    else
      @categories = Category.order(genre_id: :ASC)
    end
    @category = Category.new
  end

  def create
    @genre = Genre.new(params_genre)
    if @genre.save
      redirect_to admin_genres_path, notice: 'ジャンルを作成しました'
    else
      redirect_to admin_genres_path, alert: 'ジャンルの作成に失敗しました'
    end
  end
  
  def edit
    @genre = Genre.find(params[:id])
  end
  
  def update
    @genre = Genre.find(params[:id])
    if @genre.update(params_genre)
      redirect_to admin_genres_path, notice: 'ジャンルを変更しました'
    else
      redirect_to edit_admin_genre_path(@genre.id), alert: 'ジャンルの変更に失敗しました'
    end
  end
  
  def destroy
    @genre = Genre.find(params[:id])
    @genre.destroy!
    redirect_to admin_genres_path, notice: 'ジャンルを削除しました'
  end
  
  private
  
  def params_genre
    params.require(:genre).permit(:name)
  end
        
end
