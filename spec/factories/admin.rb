FactoryBot.define do
  # 管理者モデルのデータ
  factory :admin do
    email {  ENV['ADMIN_EMAIL'] }
    password { ENV['ADMIN_PASSWORD'] }
    password_confirmation { ENV['ADMIN_PASSWORD'] }
  end
end