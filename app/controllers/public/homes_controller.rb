class Public::HomesController < ApplicationController
  def top
    @new_recipes = Recipe.where(is_open: true).order(created_at: :desc).limit(4)
  end
end
