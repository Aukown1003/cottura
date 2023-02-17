require 'rails_helper'

describe RecipeStep, type: :model do
  describe 'レシピ材料保存時' do
    let(:user) { create(:user) }
    let(:genre) { create(:genre) }
    let(:unit) { create(:unit) }
    let!(:category) { create(:category, genre_id: genre.id) }
    let!(:recipe) { build(:recipe, user_id: user.id, category_id: category.id) }
    let!(:recipe_step) { build(:recipe_step) }
    
    it "レシピidと作り方があれば保存できる" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      recipe_step.recipe_id = recipe.id
      expect(recipe_step).to be_valid
    end
    
    it "レシピがないと保存できない" do
      recipe_step.recipe_id = nil
      recipe_step.valid?
      expect(recipe_step.errors[:recipe]).to include("がありません。")
    end
    
    it "作り方が空欄だと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      recipe_step.recipe_id = recipe.id
      recipe_step.content = nil
      recipe_step.valid?
      expect(recipe_step.errors[:content]).to include("が入力されていません。")
    end
  end
  
  describe 'アソシエーション' do
    it 'レシピの作り方とレシピは、N対1である' do
      expect(RecipeStep.reflect_on_association(:recipe).macro).to eq :belongs_to
    end
  end
end