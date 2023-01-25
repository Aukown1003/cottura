class Genre < ApplicationRecord
  
  #アソシエーション
  has_many :categories, dependent: :destroy
  
  # バリデーション
  validates :name, presence: true
end
