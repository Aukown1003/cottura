FactoryBot.define do
  # お気に入りのダミーデータ
  factory :favorite do
    user_id { association :user }
    recipe_id { association :recipe }
  end
end