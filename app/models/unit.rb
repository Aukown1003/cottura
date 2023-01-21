class Unit < ApplicationRecord
  #アソシエーション
  has_many :recipe_ingredients
  
  # バリデーション
  validates :name, presence: true
end
