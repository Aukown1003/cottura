require 'rails_helper'

describe Favorite, type: :model do
  describe 'お気に入り保存時' do
    let(:user) { create(:user) }
    let(:genre) { create(:genre) }
    let(:unit) { create(:unit) }
    let!(:category) { create(:category, genre_id: genre.id) }
    let!(:recipe) { build(:recipe, user_id: user.id, category_id: category.id) }
    let!(:favorite) { build(:favorite, user_id: user.id) }
    
    it "ユーザーid、レシピidがあれば保存できる" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      favorite.recipe_id = recipe.id
      expect(favorite).to be_valid
    end
    
    it "ログインしていないと保存できない" do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id)) 
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
      favorite.recipe_id = recipe.id
      favorite.user_id = nil
      favorite.valid?
      expect(favorite.errors[:user]).to include("がありません。")
    end
    
    it "レシピがないと保存できない" do
      favorite.recipe_id = nil
      favorite.valid?
      expect(favorite.errors[:recipe]).to include("がありません。")
    end
  end
  
  describe 'アソシエーション' do
    it 'お気に入りとレシピは、N対1である' do
      expect(Favorite.reflect_on_association(:recipe).macro).to eq :belongs_to
    end
    
    it 'お気に入りとユーザーは、N対1である' do
      expect(Favorite.reflect_on_association(:user).macro).to eq :belongs_to
    end
  end
end