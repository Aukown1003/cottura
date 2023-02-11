class Public::HomesController < ApplicationController
  def top
    @new_recipes = Recipe.by_open.ordered_by_updated_time.limit(4)
  end
end
