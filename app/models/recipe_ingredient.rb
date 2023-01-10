class RecipeIngredient < ApplicationRecord
  #アソシエーション
  belongs_to :recipe
  belongs_to :unit
  
  # バリデーション
  validates :name, presence: true
  validates :quantity, presence: true
end
