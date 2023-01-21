class CreateRecipes < ActiveRecord::Migration[6.1]
  def change
    create_table :recipes do |t|
      t.integer :user_id, null: false
      t.integer :category_id, null: false
      t.string :title, null: false
      t.string :content, null: false
      t.integer :total_time, null: false
      t.boolean :is_open, null: false, default: true
      t.timestamps
    end
  end
end
