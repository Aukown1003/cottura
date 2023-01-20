class Admin::GenresController < ApplicationController
    
    def create
      @genre = Genre.new(params_genre)
      @genre.save
      redirect_to admin_genres_path
    end
    
    def index
      @genres = Genre.all
      @genre = Genre.new
      @categories = Category.all
      @category = Category.new
    end
    
    def edit
      @genre = Genre.find(params[:id])
    end
    
    def update
      @genre = Genre.find(params[:id])
      @genre.update(params_genre)
      redirect_to admin_genres_path
    end
    
    def destroy
      @genre = Genre.find(params[:id])
      @genre.destroy
      redirect_to admin_genres_path
    end
    
    private
    
    def params_genre
      params.require(:genre).permit(:name)
    end
          
end
