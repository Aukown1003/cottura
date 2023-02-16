FactoryBot.define do
  # カテゴリーのダミーデータ
  factory :category do
    genre_id { association :genre }
    name { Faker::Food.ethnic_category }
  end
end