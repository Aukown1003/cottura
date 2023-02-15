FactoryBot.define do
  #材料のダミーデータ
  factory :recipe_step do
    content { Faker::Lorem.words(number: 20) }
  end
end