class RecipeStep < ApplicationRecord
  
  has_one_attached :image
  
  #アソシエーション
  belongs_to :recipe
  
  # バリデーション
  validates :content, presence: true
end
