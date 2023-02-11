class Recipe < ApplicationRecord
  #after_update :update_recipe_any_ingredients
  #after_update :update_recipe_any_steps
  has_one_attached :image
  attribute :payload, :text
  is_impressionable counter_cache: true

  #アソシエーション
  belongs_to :user
  belongs_to :category
  has_many :reviews, dependent: :destroy

  has_many :recipe_ingredients, dependent: :destroy
  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true

  has_many :recipe_steps, dependent: :destroy
  accepts_nested_attributes_for :recipe_steps, allow_destroy: true

  has_many :tags, dependent: :destroy
  accepts_nested_attributes_for :tags, allow_destroy: true

  has_many :favorites, dependent: :destroy
  has_many :reports, dependent: :destroy

  # バリデーション
  validates :user_id, presence: true
  validates :title, presence: true, length: {maximum: 32}
  validates :content, presence: true, length: {maximum: 140}
  validates :total_time, presence: true
  validates :recipe_ingredients, length: {minimum: 1}
  validates :recipe_steps, length: {minimum: 1}

  scope :open, -> { where(is_open: true).includes(:recipe_steps, :recipe_ingredients) }
  scope :ordered_by_updated_time, -> { order(updated_at: :asc) }
  scope :by_category, -> (id) { where(category: id) }
  scope :by_time, -> (time) { where(total_time: ..time) }

  def favorited_by(user)
    favorites.exists?(user_id: user.id)
  end


  def attach_default_image
    file_path = Rails.root.join('app/assets/images/no_image_item.png')
    image.attach(io: File.open(file_path), filename: 'default-recipe-image.png', content_type: 'image/png')
  end

  def get_recipe_image(width, height)
    attach_default_image unless image.attached?
    image.variant(resize_to_fill: [width, height]).processed
  end

  # def get_recipe_image(width, height)
  #   unless image.attached?
  #     file_path = Rails.root.join('app/assets/images/no_image_item.png')
  #     image.attach(io: File.open(file_path), filename: 'default-recipe-image.png', content_type: 'image/png')
  #   end
  #   image.variant(resize_to_fill: [width, height]).processed
  # end

  # def get_recipe_index_image(width, height)
  #   unless image.attached?
  #     file_path = Rails.root.join('app/assets/images/no_image_item.png')
  #     image.attach(io: File.open(file_path), filename: 'default-recipe-image.png', content_type: 'image/png')
  #   end
  #   image.variant(resize_to_fill: [width, height]).processed
  # end

  # 調理時間、絞り込み時間一覧作成メソッド
  def self.time_data(hour, min, suffix = "")
    data = []
    count = hour * (60 / min)
    (1..count).each { |x|
      total_min = min * x
      if total_min < 60
        time = "#{total_min}分#{suffix}"
      elsif total_min % 60 == 0
        time = "#{total_min / 60}時間#{suffix}"
      else
        time = "#{total_min / 60}時間" + "#{ total_min % 60 }分#{suffix}"
      end
        arr = [time, total_min]
        data.push(arr)
    }
    return data
  end
end
