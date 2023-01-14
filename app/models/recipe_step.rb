class RecipeStep < ApplicationRecord
  
  has_one_attached :image
  
  #アソシエーション
  belongs_to :recipe
  
  # バリデーション
  validates :content, presence: true
  
  
  def get_recipe_step_image(width, height)
    # binding.pry
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/no_image_item.png')
      image.attach(io: File.open(file_path), filename: 'default-recipe-image.png', content_type: 'image/png')
    end
    # image.variant(resize_to_limit: [width, height]).processed
    image.variant(resize_to_fill: [width, height])
    # image
  end
end
