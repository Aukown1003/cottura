class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.integer :recipe_id, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
