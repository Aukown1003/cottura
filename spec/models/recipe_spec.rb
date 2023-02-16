require 'rails_helper'

describe Recipe, type: :model do
  describe 'レシピ保存時' do
    let(:user) { create(:user) }
    let(:genre) { create(:genre) }
    let(:unit) { create(:unit) }
    let!(:category) { create(:category, genre_id: genre.id) }
    let!(:recipe) { build(:recipe, user_id: user.id, category_id: category.id) }
    
    
    it "レシピ名、調理時間、調理時間があれば保存できる" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      expect(recipe).to be_valid
    end
  
    it "材料、作り方が一つ以上無いと保存できない" do
      recipe.valid?
      expect(recipe.errors[:recipe_ingredients]).to include("は一つ以上入力してください。")
      expect(recipe.errors[:recipe_steps]).to include("は一つ以上入力してください。")
    end
    
    it "材料が一つ以上無いと保存できない" do
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.valid?
      expect(recipe.errors[:recipe_ingredients]).to include("は一つ以上入力してください。")
    end
    
    it "作り方が一つ以上無いと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
      recipe.valid?
      expect(recipe.errors[:recipe_steps]).to include("は一つ以上入力してください。")
    end
    
    it "レシピ名が空欄だと保存できない" do
      recipe.title = nil
      recipe.valid?
      expect(recipe.errors[:title]).to include("が入力されていません。")
    end
    
    it "レシピ名が33文字以上だと保存できない" do
      invalid_title = Faker::Lorem.characters(number: 33)
      recipe.title = invalid_title
      recipe.valid?
      expect(recipe.errors[:title]).to include("が制限数を超えて入力されています")
    end
    
    it "レシピ紹介が空欄だと保存できない" do
      recipe.content = nil
      recipe.valid?
      expect(recipe.errors[:content]).to include("が入力されていません。")
    end
    
    it "レシピ紹介が141文字以上だと保存できない" do
      invalid_content = Faker::Lorem.characters(number: 141)
      recipe.content = invalid_content
      recipe.valid?
      expect(recipe.errors[:content]).to include("が制限数を超えて入力されています")
    end
    
    it "調理時間が未選択だと保存できない" do
      recipe.total_time = nil
      recipe.valid?
      expect(recipe.errors[:total_time]).to include("が未選択です。")
    end
    
    it "ログインしていないと保存できない" do
      recipe.user = nil
      recipe.valid?
      expect(recipe.errors[:user]).to include("が選択されていません。")
    end
    
    it "カテゴリーが未選択だと保存できない" do
      recipe.category = nil
      recipe.valid?
      expect(recipe.errors[:category]).to include("が選択されていません。")
    end
  end
  
  describe 'アソシエーション' do
    it 'レシピとユーザーは、N対1である' do
      expect(Recipe.reflect_on_association(:user).macro).to eq :belongs_to
    end
    
    it 'レシピとカテゴリーは、N対1である' do
      expect(Recipe.reflect_on_association(:category).macro).to eq :belongs_to
    end
    
    it 'レシピとレシピの材料は、1対Nである' do
      expect(Recipe.reflect_on_association(:recipe_ingredients).macro).to eq :has_many
    end
    
    it 'レシピとレシピの作り方は、1対Nである' do
      expect(Recipe.reflect_on_association(:recipe_steps).macro).to eq :has_many
    end
    
    it 'レシピとレビューは、1対Nである' do
      expect(Recipe.reflect_on_association(:reviews).macro).to eq :has_many
    end
    
    it 'レシピとタグは、1対Nである' do
      expect(Recipe.reflect_on_association(:tags).macro).to eq :has_many
    end
    
    it 'レシピとお気にいりは、1対Nである' do
      expect(Recipe.reflect_on_association(:favorites).macro).to eq :has_many
    end
    
    it 'レシピとレポートは、1対Nである' do
      expect(Recipe.reflect_on_association(:reports).macro).to eq :has_many
    end
  end
end