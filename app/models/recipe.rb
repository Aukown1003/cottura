class Recipe < ApplicationRecord
  #アソシエーション
  belongs_to :user
  
  has_many :recipe_ingredients
  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true
  
  has_many :recipe_steps
  accepts_nested_attributes_for :recipe_stes, allow_destroy: true
  
  # バリデーション
  validates :user_id, presence: true
  validates :title, presence: true
  validates :content, presence: true
  validates :total_time, presence: true
end
