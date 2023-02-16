require 'rails_helper'

describe Report, type: :model do
  describe 'レポート保存時' do
    let(:user) { create(:user) }
    let(:genre) { create(:genre) }
    let(:unit) { create(:unit) }
    let!(:category) { create(:category, genre_id: genre.id) }
    let!(:recipe) { build(:recipe, user_id: user.id, category_id: category.id) }
    let!(:report) { build(:report, user_id: user.id, recipe_id: recipe.id) }
    
    it "ユーザーid、レシピid、報告内容があれば保存できる" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      report.recipe_id = recipe.id
      expect(report).to be_valid
    end
    
    it "ログインしていないと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      report.recipe_id = recipe.id
      report.user_id = nil
      report.valid?
      expect(report.errors[:user]).to include("がありません。")
    end
    
    it "レシピがないと保存できない" do
      report.recipe_id = nil
      report.valid?
      expect(report.errors[:recipe]).to include("がありません。")
    end
    
    it "報告内容が無いと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      report.recipe_id = recipe.id
      report.content = nil
      report.valid?
      expect(report.errors[:content]).to include("が入力されていません。")
    end
  end
  
  describe 'アソシエーション' do
    it 'お気に入りとレシピは、N対1である' do
      expect(Report.reflect_on_association(:recipe).macro).to eq :belongs_to
    end
    
    it 'お気に入りとユーザーは、N対1である' do
      expect(Report.reflect_on_association(:user).macro).to eq :belongs_to
    end
  end
end