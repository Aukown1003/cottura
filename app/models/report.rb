class Report < ApplicationRecord
  # アソシエーション
  belongs_to :user
  belongs_to :recipe

  # バリデーション
  validates :content, presence: true
  
  # スコープ
  scope :with_user_and_recipe, -> { includes(:user, recipe: :user) }
end
