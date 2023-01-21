class Review < ApplicationRecord
  # アソシエーション
  belongs_to :user
  belongs_to :recipe
  
  # バリデーション
  validates :user_id, presence: true
  validates :recipe_id, presence: true
  validates :content, presence: true
  validates :score, presence: true
end
