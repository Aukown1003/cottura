class Category < ApplicationRecord
  
  #アソシエーション
  has_many :recipes, dependent: :destroy
  belongs_to :genre
end
