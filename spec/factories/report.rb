FactoryBot.define do
  # レポートのダミーデータ
  factory :report do
    user_id { association :user }
    recipe_id { association :recipe }
    content { Faker::Lorem.words(number: 20) }
  end
end