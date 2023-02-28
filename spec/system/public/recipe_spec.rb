require 'rails_helper'


Capybara.javascript_driver = :selenium
RSpec.describe "レシピの総合テスト", type: :system do
  before do
    @user = create(:user)
    sign_in @user
  end
  
  let(:genre) { create(:genre) }
  let!(:category) { create(:category, genre_id: genre.id) }
  let!(:recipe) { build(:recipe, user_id: @user.id, category_id: category.id) }
  let!(:posted_recipe) { create(:recipe, :with_recipe_ingredient, :with_recipe_step, user_id: @user.id, category_id: category.id) }
  
  
  
  
  describe '新規レシピ投稿' do
    context '正常系' do
      it 'test' do
        visit new_recipe_path
        fill_in 'recipe_title', with: recipe.title
        fill_in 'recipe_content', with: recipe.content
        select '1時間30分', from: 'recipe[total_time]'
      end
    end
    context '異常系' do
    end
  end
end