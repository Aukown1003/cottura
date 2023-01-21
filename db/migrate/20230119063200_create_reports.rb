class CreateReports < ActiveRecord::Migration[6.1]
  def change
    create_table :reports do |t|
      t.integer :user, null: false
      t.integer :recipe, null: false
      t.text :content, null: false
      t.timestamps
    end
  end
end
