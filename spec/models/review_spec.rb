require 'rails_helper'

describe Review, type: :model do
  describe 'レビュー保存時' do
    let(:user) { create(:user) }
    let(:genre) { create(:genre) }
    let(:unit) { create(:unit) }
    let!(:category) { create(:category, genre_id: genre.id) }
    let!(:recipe) { build(:recipe, user_id: user.id, category_id: category.id) }
    let!(:review) { build(:review, user_id: user.id, recipe_id: recipe.id) }
    
    it "ユーザーid、レシピid、レビュー内容があれば保存できる" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      review.recipe_id = recipe.id
      expect(review).to be_valid
    end
    
    it "ログインしていないと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      review.recipe_id = recipe.id
      review.user_id = nil
      review.valid?
      expect(review.errors[:user]).to include("がありません。")
    end
    
    it "レシピがないと保存できない" do
      review.recipe_id = nil
      review.valid?
      expect(review.errors[:recipe]).to include("がありません。")
    end
    
    it "レビュー内容が無いと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      review.recipe_id = recipe.id
      review.content = nil
      review.valid?
      expect(review.errors[:content]).to include("が入力されていません。")
    end
  end
  
  describe 'アソシエーション' do
    it 'レビューとレシピは、N対1である' do
      expect(Review.reflect_on_association(:recipe).macro).to eq :belongs_to
    end
    
    it 'レビューとユーザーは、N対1である' do
      expect(Review.reflect_on_association(:user).macro).to eq :belongs_to
    end
  end
end