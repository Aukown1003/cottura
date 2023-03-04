FactoryBot.define do
  #材料のダミーデータ
  factory :recipe_step do
    recipe_id { association :recipe }
    content { "作り方1" }
  end
end