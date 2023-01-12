class Recipe < ApplicationRecord
  
  has_one_attached :image
  
  #アソシエーション
  belongs_to :user
  
  has_many :recipe_ingredients
  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true
  
  has_many :recipe_steps
  accepts_nested_attributes_for :recipe_steps, allow_destroy: true
  
  # バリデーション
  validates :user_id, presence: true
  validates :title, presence: true, length: {maximum: 32}
  validates :content, presence: true, length: {maximum: 140}
  validates :total_time, presence: true
  validates :is_open, presence: true
  
  
  
  def get_recipe_image(width, height)
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/no_image_item.png')
      image.attach(io: File.open(file_path), filename: 'default-recipe-image.png', content_type: 'image/png')
    end
    # image.variant(resize_to_limit: [width, height]).processed
    image.variant(resize_to_fill: [width, height]).processed
  end
  
  # 調理時間作成メソッド
  def self.select_time_data
    # 登録したい時間
    hour = 7
    # 何分刻みで登録するか
    min = 15
    
    # 配列の作成
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
  
end
