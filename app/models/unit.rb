class Unit < ApplicationRecord
  #アソシエーション
  has_many :recipe_ingredients, dependent: :destroy
  
  # バリデーション
  validates :name, presence: true
  
  # スコープ
  scope :with_recipe_ingredients, -> { includes(:recipe_ingredients) }
end
