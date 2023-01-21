class CreateRecipeSteps < ActiveRecord::Migration[6.1]
  def change
    create_table :recipe_steps do |t|
      t.integer :recipe_id, null: false
      t.text :content, null: false
      t.timestamps
    end
  end
end
