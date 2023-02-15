FactoryBot.define do
  # カテゴリーのダミーデータ
  factory :category do
    association :genre
    name { Faker::Food.ethnic_category }
  end
end