class Unit < ApplicationRecord
  #アソシエーション
  has_many :recipe_ingredients, dependent: :destroy
  
  # バリデーション
  validates :name, presence: true
end
