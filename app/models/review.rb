class Review < ApplicationRecord
  # アソシエーション
  belongs_to :user
  belongs_to :recipe
  
  # バリデーション
  validates :content, presence: true
  validates :score, presence: true
end
