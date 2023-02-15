FactoryBot.define do
  # 単位のダミーデータ
  factory :unit do
    name { Faker::Lorem.words(number: 3) }
  end
end