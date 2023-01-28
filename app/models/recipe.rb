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

  def favorited_by(user)
    favorites.exists?(user_id: user.id)
  end

  def get_recipe_image(width, height)
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/no_image_item.png')
      image.attach(io: File.open(file_path), filename: 'default-recipe-image.png', content_type: 'image/png')
    end
    image.variant(resize_to_limit: [width, height]).processed
  end

  def get_recipe_index_image(width, height)
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/no_image_item.png')
      image.attach(io: File.open(file_path), filename: 'default-recipe-image.png', content_type: 'image/png')
    end
    image.variant(resize_to_fill: [width, height]).processed

  end

  # 調理時間作成メソッド
  def self.select_time_data
    # 登録したい時間
    hour = 7
    # 何分刻みで登録するか
    min = 15

    data = []
    count = hour * (60 / min)
    (1..count).each { |x|
      total_min = min * x
      if total_min < 60
        time = "#{total_min}分"
      elsif total_min % 60 == 0
        time = "#{total_min / 60}時間"
      else
        time = "#{total_min / 60}時間" + "#{ total_min % 60 }分"
      end
        arr = [time, total_min]
        data.push(arr)
    }
    return data
  end
  
    # 調理時間絞り込み要メソッド
  def self.search_time_data
    # 登録したい時間
    hour = 3
    # 何分刻みで登録するか
    min = 30

    data = []
    count = hour * (60 / min)
    (1..count).each { |x|
      total_min = min * x
      if total_min < 60
        time = "#{total_min}分以内"
      elsif total_min % 60 == 0
        time = "#{total_min / 60}時間以内"
      else
        time = "#{total_min / 60}時間" + "#{ total_min % 60 }分以内"
      end
        arr = [time, total_min]
        data.push(arr)
    }
    return data
  end

end
