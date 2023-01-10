class RecipeStep < ApplicationRecord
  #アソシエーション
  belongs_to :recipe
  
  # バリデーション
  validates :content, presence: true
end
