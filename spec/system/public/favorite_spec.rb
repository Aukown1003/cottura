require 'rails_helper'


Capybara.javascript_driver = :selenium
RSpec.describe "レシピの総合テスト", type: :system do
  before do
    @user = create(:user)
    @user2 = create(:user)
    @gest_user = create(:user, email: "guest@example.com")
    @admin = create(:admin)
    sign_in @user
  end
  
  let(:genre) { create(:genre, name: 'ごはん・主食') }
  let!(:category) { create(:category, name: 'どんぶりや混ぜご飯', genre_id: genre.id) }
  let!(:unit) { create(:unit, name: 'g') }
  let!(:posted_recipe) { create(:recipe, :with_recipe_ingredient, :with_recipe_step, user_id: @user2.id, category_id: category.id) }
  let!(:posted_recipe_create_sign_in_user) { create(:recipe, :with_recipe_ingredient, :with_recipe_step, user_id: @user2.id, category_id: category.id) }
  
  describe 'レシピのお気に入り登録' do
    it '登録したレシピがマイページのお気に入り一覧で正しく表示されている' do
      visit recipe_path(posted_recipe.id)
      click_link "お気に入り登録"
      
      visit user_path(@user.id)
      find('li.tab-B').click
      expect(page).to have_content(posted_recipe.title)
    end
  end
  
end
