class Tag < ApplicationRecord
  
  #アソシエーション
  belongs_to :recipe
  
  # バリデーション
  validates :name, presence: true
  
end
