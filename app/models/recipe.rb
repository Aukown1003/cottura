class Recipe < ApplicationRecord
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
  validates :title, presence: true, length: {maximum: 32}
  validates :content, presence: true, length: {maximum: 140}
  validates :total_time, presence: true
  validates :recipe_ingredients, length: {minimum: 1}
  validates :recipe_steps, length: {minimum: 1}
  
  # スコープ
  scope :with_user, -> { includes(:user) }
  scope :with_reviews, -> { includes(:reviews) }
  scope :with_ingredient_and_step, -> { includes(:recipe_steps, :recipe_ingredients) }
  scope :with_recipe_detail_and_review, -> { includes(:recipe_ingredients, :recipe_steps, :tags, :reviews) }
  scope :by_open, -> { where(is_open: true) }
  scope :by_show_user, ->(user) { where(users: {id: user.id}) }
  scope :by_category, -> (id) { where(category: id) }
  scope :by_time, -> (time) { where(total_time: ..time) }
  scope :ordered_by_updated_time, -> { order(updated_at: :desc) }

  # お気に入りに登録しているかの確認
  def favorited_by(user)
    favorites.exists?(user_id: user.id)
  end

  # デフォルトイメージの設定
  def attach_default_image
    file_path = Rails.root.join('app/assets/images/no_image_item.png')
    image.attach(io: File.open(file_path), filename: 'default-recipe-image.png', content_type: 'image/png')
  end
  
  # レシピイメージの設定
  def get_recipe_image(width, height)
    attach_default_image unless image.attached?
    image.variant(resize_to_fill: [width, height]).processed
  end
  
  # レシピの検索
  def self.search_by_keyword(keyword, search_datas)
    keywords = keyword.split(/ |　/).uniq.compact
    search_datas.each do |recipe|
      recipe.assign_attributes(payload: (
        recipe.recipe_steps.pluck(:content).join +
        recipe.recipe_ingredients.pluck(:name).join +
        recipe.tags.pluck(:name).join +
        recipe.title
      ))
    end
    search_datas.select do |o|
      result = keywords.map{ |k| o.payload.include?(k) }
      result.compact.uniq.size == 1 && result.compact.uniq.first == true
    end
  end
  
  # 絞り込み表示用のカテゴリーIDのセッションへの登録
  def self.add_category_id_to_session(params_data, session)
    if session[:category_id].present?
      base_data = session[:category_id]
      base_data << params_data
    else
      base_data = Array(params_data)
    end
    base_data.uniq!
    session[:category_id] = base_data
  end
  
  # レシピ材料の分量の再計算
  def self.calculate_ratio(recipe_ingredient_id, quantity_data)
    ingredient_quantity = RecipeIngredient.find(recipe_ingredient_id).quantity
    (BigDecimal(quantity_data.to_s) / ingredient_quantity).to_f
  end
  
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
