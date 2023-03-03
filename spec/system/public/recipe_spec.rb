require 'rails_helper'


Capybara.javascript_driver = :selenium
RSpec.describe "レシピの総合テスト", type: :system do
  before do
    @user = create(:user)
    sign_in @user
  end
  
  let(:genre) { create(:genre, name: 'ごはん・主食') }
  let!(:category) { create(:category, name: 'どんぶりや混ぜご飯', genre_id: genre.id) }
  let!(:unit) { create(:unit, name: 'g') }
  let!(:recipe) { build(:recipe, user_id: @user.id, category_id: category.id) }
  let!(:posted_recipe) { create(:recipe, :with_recipe_ingredient, :with_recipe_step, user_id: @user.id, category_id: category.id) }
  
  describe '新規レシピ投稿' do
    context '正常系' do
      before { visit new_recipe_path }
      
      it 'レシピ名フォームが表示される' do
        expect(page).to have_field 'recipe[title]'
      end
      
      it 'レシピ紹介文フォームが表示される' do
        expect(page).to have_field 'recipe[content]'
      end
      
      it '調理時間選択フォームが表示される' do
        expect(page).to have_field 'recipe[total_time]'
      end
      
      it 'ジャンル選択フォームが表示される' do
        expect(page).to have_field 'recipe[genre_id]'
      end
      
      it 'カテゴリー選択フォームが入力不可(disabled)で表示される' do
        expect(page).to have_field('recipe[category_id]', disabled: true)
      end
      
      it '公開で選択されている' do
        expect(page).to have_checked_field with: 'true', visible: false
      end
      
      it 'レシピを投稿するボタンが表示される' do
        expect(page).to have_button 'レシピを投稿する'
      end
      
      
      
      it 'レシピが投稿できる' do
        fill_in 'recipe[title]', with: "recipe_title"
        fill_in 'recipe[content]', with: "recipe_content"
        select '1時間30分', from: 'recipe[total_time]'
        select 'ごはん・主食', from: 'recipe[genre_id]', visible: false
        select 'どんぶりや混ぜご飯', from: 'recipe[category_id]', visible: false, disabled: false
        click_link "材料の追加"
        find(".ingredient-name").set("レシピ材料1")
        find(".ingredient-quantity").set(100)
        click_link "作り方の追加"
        find(".step-content").set("レシピステップ1")
        # 公開状況と単位の選択がデフォルトのままで行われている。方法を確立すること
        expect { click_button 'レシピを投稿する' }.to change { Recipe.count }.by(1)
      end
      
    end
    context '異常系' do
    end
  end
end