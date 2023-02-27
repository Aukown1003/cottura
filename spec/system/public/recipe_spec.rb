require 'rails_helper'


Capybara.javascript_driver = :selenium
RSpec.describe "レシピの総合テスト", type: :system do
  before do
    @user = create(:user)
    #request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
  end
  
  let(:genre) { create(:genre) }
  let(:unit) { create(:unit) }
  let!(:category) { create(:category, genre_id: genre.id) }
  let!(:recipe) { build(:recipe, user_id: @user.id, category_id: category.id) }
  # byebug
  let!(:posted_recipe) { create(:recipe, :with_recipe_ingredient, :with_recipe_step, user_id: @user.id, category_id: category.id) }
  
  
  
  
  describe '新規レシピ投稿' do
    context '正常系' do
      it 'test' do
        visit root_path
        # binding.pry
        p find_all('p')[0].text
      end
    end
    context '異常系' do
    end
  end
end