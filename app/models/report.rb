class Report < ApplicationRecord
<<<<<<< .merge_file_C8z7q7
  # アソシエーション
  belongs_to :user
  belongs_to :recipe

  # バリデーション
  validates :user_id, presence: true
  validates :recipe_id, presence: true
  validates :content, presence: true
=======
  belongs_to :user
  belongs_to :recipe
>>>>>>> .merge_file_dUsRqX
end
