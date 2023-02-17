FactoryBot.define do
  # レシピモデルのダミーデータ
  factory :recipe do
    user_id { association :user }
    category_id { association :category }
    title { Faker::Lorem.characters(number: 20) }
    content { Faker::Lorem.characters(number: 20) }
    total_time { Faker::Number.number(digits: 3) }
    is_open { "true" }
    impressions_count { 0 }
    payload { nil }
  end
end