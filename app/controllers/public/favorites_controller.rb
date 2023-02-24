class Public::FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @recipe = Recipe.find(params[:recipe_id])
    favorite = current_user.favorites.new(recipe_id: params[:recipe_id])
    favorite.save!
  end
  
  def destroy
    @recipe = Recipe.find(params[:recipe_id])
    favorite = current_user.favorites.find_by(recipe_id: params[:recipe_id])
    favorite.destroy!
  end
  
end
