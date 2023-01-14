class Category < ApplicationRecord
  
  #アソシエーション
  has_many :users, dependent: :destroy
  belongs_to :genre
end
