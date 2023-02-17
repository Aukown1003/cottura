FactoryBot.define do
  # タグのダミーデータ
  factory :tag do
    recipe_id { association :recipe }
    name { Faker::Lorem.words(number: 5) }
  end
end