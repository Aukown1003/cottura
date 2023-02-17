FactoryBot.define do
  # ジャンルのダミーデータ
  factory :genre do
    name { Faker::Food.dish }
  end
end