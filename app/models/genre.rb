class Genre < ApplicationRecord
  
  #アソシエーション
  has_many :categories, dependent: :destroy
end
