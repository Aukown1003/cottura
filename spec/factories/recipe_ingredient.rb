FactoryBot.define do
  #材料のダミーデータ
  factory :recipe_ingredient do
    recipe_id { association :recipe }
    association :unit 
    name { "材料名1" }
    quantity { 100 }
  end
end