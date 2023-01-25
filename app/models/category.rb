class Category < ApplicationRecord
  
  #アソシエーション
  has_many :recipes, dependent: :destroy
  belongs_to :genre
  
  # バリデーション
  validates :name, presence: true
  validates :genre_id, presence: true
end
