class Admin::CategoriesController < ApplicationController
    def create
      @category = Category.new(params_category)
      @category.name = params[:category][:name]
      @category.genre_id = params[:category][:genre_id]
      @category.save
      redirect_to admin_genres_path
    end

    def edit
      @category = Category.find(params[:id])
    end

    def update
      @category = Category.find(params[:id])
      @category.update(params_category)
      redirect_to admin_genres_path
    end

    def destroy
      @category = Category.find(params[:id])
      @category.destroy
      redirect_to admin_genres_path
    end

    private
    def params_category
      params.require(:category).permit(:genre_id, :name)
    end
end
