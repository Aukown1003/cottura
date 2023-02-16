class Category < ApplicationRecord
  
  #アソシエーション
  has_many :recipes, dependent: :destroy
  belongs_to :genre
  
  # バリデーション
  validates :name, presence: true
  # validates :genre_id, presence: true
  
  # スコープ
  scope :by_id, -> (id) { where(id: id) }
  scope :by_genre, -> (genre_id) { where(genre_id: genre_id) }
end
