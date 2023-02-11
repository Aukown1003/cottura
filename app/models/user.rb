class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :image

  # バリデーション
  validates :name, presence: true
  validates :email, presence: true
  validates :content, presence: true

  # アソシエーション
  has_many :recipes, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_recipes, through: :favorites, source: :recipe
  has_many :reports, dependent: :destroy

  # ユーザーアカウント状態メソッド
  def active?
    if self.is_active == true
      "有効"
    else
      "退会"
    end
  end

  # 画像のリサイズ、及びデフォルト画像の設定メソッド
  def get_user_image(width, height)
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/no_image_user.png')
      image.attach(io: File.open(file_path), filename: 'default-user-image.png', content_type: 'image/png')
    end
    image.variant(resize_to_fill: [width, height]).processed
  end

  # ゲストユーザーログインメソッド
  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "ゲストユーザー"
      user.content = "ゲストユーザーでログイン中！"
    end
  end
  
  # ユーザーの状態確認メソッド
  def active_for_authentication?
    super && (is_active == true)
  end

end
