require 'rails_helper'

describe RecipeIngredient, type: :model do
  describe 'レシピ材料保存時' do
    let(:user) { create(:user) }
    let(:genre) { create(:genre) }
    let(:unit) { create(:unit) }
    let!(:category) { create(:category, genre_id: genre.id) }
    let!(:recipe) { build(:recipe, user_id: user.id, category_id: category.id) }
    let!(:recipe_ingredient) { build(:recipe_ingredient, unit_id: unit.id) }
    
    it "レシピidと材料名、材料の単位があれば保存できる" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      recipe_ingredient.recipe_id = recipe.id
      expect(recipe_ingredient).to be_valid
    end
    
    it "レシピがないと保存できない" do
      recipe_ingredient.recipe_id = nil
      recipe_ingredient.valid?
      expect(recipe_ingredient.errors[:recipe]).to include("がありません。")
    end
    
    it "材料名が空欄だと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      recipe_ingredient.recipe_id = recipe.id
      recipe_ingredient.name = nil
      recipe_ingredient.valid?
      expect(recipe_ingredient.errors[:name]).to include("が入力されていません。")
    end
    
    it "材料の分量が空欄だと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      recipe_ingredient.recipe_id = recipe.id
      recipe_ingredient.quantity = nil
      recipe_ingredient.valid?
      expect(recipe_ingredient.errors[:quantity]).to include("が入力されていません。")
    end
    
    it "材料の単位がないと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      recipe_ingredient.recipe_id = recipe.id
      recipe_ingredient.unit_id = nil
      recipe_ingredient.valid?
      expect(recipe_ingredient.errors[:unit]).to include("が選択されていません。")
    end
  end
  
  describe 'アソシエーション' do
    it 'レシピ材料とレシピは、N対1である' do
      expect(RecipeIngredient.reflect_on_association(:recipe).macro).to eq :belongs_to
    end
    
    it 'レシピ材料と材料の単位は、N対1である' do
      expect(RecipeIngredient.reflect_on_association(:unit).macro).to eq :belongs_to
    end
  end
end