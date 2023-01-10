class RecipeStep < ApplicationRecord
  #アソシエーション
  belongs_to :recipe
  
  # バリデーション
  validates :quantity, presence: true
end
