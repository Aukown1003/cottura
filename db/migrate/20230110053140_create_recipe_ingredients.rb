class CreateRecipeIngredients < ActiveRecord::Migration[6.1]
  def change
    create_table :recipe_ingredients do |t|
      t.integer :recipe_id, null: false
      t.integer :unit_id, null: false
      t.string :name, null: false
      t.integer :quantity, null: false
      t.timestamps
    end
  end
end
