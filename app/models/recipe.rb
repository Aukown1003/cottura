class Recipe < ApplicationRecord
  #アソシエーション
  belongs_to :user
  
  # バリデーション
  validates :user_id, presence: true
  validates :title, presence: true
  validates :content, presence: true
  validates :total_time, presence: true
end
