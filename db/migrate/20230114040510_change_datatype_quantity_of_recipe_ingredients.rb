class ChangeDatatypeQuantityOfRecipeIngredients < ActiveRecord::Migration[6.1]
  def change
    change_column :recipe_ingredients, :quantity, :float
  end
end
