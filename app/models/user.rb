class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_one_attached :image
  
  def get_user_image(width, height)
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/no_image_user.png')
      image.attach(io: File.open(file_path), filename: 'default-user-image.png', content_type: 'image/png')
    end
    # image.variant(resize_to_limit: [width, height]).processed
    image.variant(resize_to_fill: [width, height]).processed
  end
  
  def self.guest
    find_or_create_by!(name: 'guestuser' ,email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "ゲストユーザー"
      user.content = "ゲストユーザーでログイン中！"
    end
  end
  
end
