require 'rails_helper'

describe RecipeStep, type: :model do
  describe 'レシピ材料保存時' do
    let(:user) { create(:user) }
    let(:genre) { create(:genre) }
    let(:unit) { create(:unit) }
    let!(:category) { create(:category, genre_id: genre.id) }
    let!(:recipe) { build(:recipe, user_id: user.id, category_id: category.id) }
    let!(:tag) { build(:tag) }
    
    it "レシピidとタグ名があれば保存できる" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      tag.recipe_id = recipe.id
      expect(tag).to be_valid
    end
    
    it "レシピがないと保存できない" do
      tag.recipe_id = nil
      tag.valid?
      expect(tag.errors[:recipe]).to include("がありません。")
    end
    
    it "タグ名が空欄だと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      tag.recipe_id = recipe.id
      tag.name = nil
      tag.valid?
      expect(tag.errors[:name]).to include("が入力されていません。")
    end
  end
  
  describe 'アソシエーション' do
    it 'タグとレシピは、N対1である' do
      expect(Tag.reflect_on_association(:recipe).macro).to eq :belongs_to
    end
  end
end