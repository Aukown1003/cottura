FactoryBot.define do
  # パスワードの設定
  password = Faker::Internet.password(min_length: 6, max_length: 8)
  
  # ユーザーモデルのダミーデータ
  factory :user do
    # specifier..: min_length, max_length
    name { Faker::Internet.username(specifier: 5..8) }
    email { Faker::Internet.email(domain: 'example') }
    content { Faker::Lorem.characters(number:15) }
    password { password }
    password_confirmation { password }
    is_active { "true" }
  end
end