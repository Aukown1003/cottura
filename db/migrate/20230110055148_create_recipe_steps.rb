class CreateRecipeSteps < ActiveRecord::Migration[6.1]
  def change
    create_table :recipe_steps do |t|
      t.references :recipe, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamps
    end
  end
end
