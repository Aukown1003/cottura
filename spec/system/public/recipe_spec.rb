require 'rails_helper'


Capybara.javascript_driver = :selenium
RSpec.describe "レシピの総合テスト", type: :system do
  before do
    @user = create(:user)
    @gest_user = create(:user, email: "guest@example.com")
    @admin = create(:admin)
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
      
      it '最初は公開で選択されており、非公開をクリックすることで選択が切り替わる' do
        expect(page).to have_checked_field with: 'true', visible: false
        find('label[for=recipe_is_open_false]').click 
        expect(page).to have_selector('input[name="recipe[is_open]"][value="false"]:checked', count: 1, visible: false)
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
        select 'g'
        click_link "作り方の追加"
        find(".step-content").set("レシピステップ1")
        find('label[for=recipe_is_open_true]').click 
        expect { click_button 'レシピを投稿する' }.to change { Recipe.count }.by(1)
      end
      
    end
    context '異常系' do
      before { visit new_recipe_path }
      
      it "レシピ名か、レシピ紹介、調理時間が未選択であると送信できず入力するように促される" do
        fill_in 'recipe[title]', with: nil
        fill_in 'recipe[content]', with: nil
        select 'ごはん・主食', from: 'recipe[genre_id]', visible: false
        select 'どんぶりや混ぜご飯', from: 'recipe[category_id]', visible: false, disabled: false
        click_link "材料の追加"
        find(".ingredient-name").set("レシピ材料1")
        find(".ingredient-quantity").set(100)
        select 'g'
        click_link "作り方の追加"
        find(".step-content").set("レシピステップ1")
        find('label[for=recipe_is_open_true]').click 
        click_button 'レシピを投稿する'
        expect(page).to have_current_path(new_recipe_path)
      end
      
      it '材料と作り方が未入力だと、レシピが保存できない' do
        fill_in 'recipe[title]', with: "recipe_title"
        fill_in 'recipe[content]', with: "recipe_content"
        select '1時間30分', from: 'recipe[total_time]'
        select 'ごはん・主食', from: 'recipe[genre_id]', visible: false
        select 'どんぶりや混ぜご飯', from: 'recipe[category_id]', visible: false, disabled: false
        find('label[for=recipe_is_open_true]').click
        click_button 'レシピを投稿する'
        expect(page).to have_content("材料 は一つ以上入力してください。")
        expect(page).to have_content("作り方 は一つ以上入力してください。")
      end
      
      it '材料名、分量が未入力であるとレシピが保存できない' do
        fill_in 'recipe[title]', with: "recipe_title"
        fill_in 'recipe[content]', with: "recipe_content"
        select '1時間30分', from: 'recipe[total_time]'
        select 'ごはん・主食', from: 'recipe[genre_id]', visible: false
        select 'どんぶりや混ぜご飯', from: 'recipe[category_id]', visible: false, disabled: false
        click_link "材料の追加"
        find(".ingredient-name").set(nil)
        find(".ingredient-quantity").set(nil)
        select 'g'
        click_link "作り方の追加"
        find(".step-content").set("レシピステップ1")
        find('label[for=recipe_is_open_true]').click 
        click_button 'レシピを投稿する'
        expect(page).to have_content("材料名 が入力されていません。")
        expect(page).to have_content("分量 が入力されていません。")
      end
      
      it '作り方が未入力であるとレシピが保存できない' do
        fill_in 'recipe[title]', with: "recipe_title"
        fill_in 'recipe[content]', with: "recipe_content"
        select '1時間30分', from: 'recipe[total_time]'
        select 'ごはん・主食', from: 'recipe[genre_id]', visible: false
        select 'どんぶりや混ぜご飯', from: 'recipe[category_id]', visible: false, disabled: false
        click_link "材料の追加"
        find(".ingredient-name").set("レシピ材料1")
        find(".ingredient-quantity").set(100)
        select 'g'
        click_link "作り方の追加"
        find(".step-content").set(nil)
        find('label[for=recipe_is_open_true]').click 
        click_button 'レシピを投稿する'
        expect(page).to have_content("作り方の詳細 が入力されていません。")
      end
      
      it 'ジャンル、カテゴリーが未選択だと、レシピが保存できない' do
        fill_in 'recipe[title]', with: "recipe_title"
        fill_in 'recipe[content]', with: "recipe_content"
        select '1時間30分', from: 'recipe[total_time]'
        click_link "材料の追加"
        find(".ingredient-name").set("レシピ材料1")
        find(".ingredient-quantity").set(100)
        select 'g'
        click_link "作り方の追加"
        find(".step-content").set("レシピステップ1")
        find('label[for=recipe_is_open_true]').click 
        click_button 'レシピを投稿する'
        expect(page).to have_content("カテゴリー が選択されていません。")
      end
    end
  end
  
  describe 'レシピ詳細' do
    
    it '登録したレシピのデータが正しく表示されている' do
      visit recipe_path(posted_recipe.id)
      expect(page).to have_content(posted_recipe.title)
      expect(page).to have_content(posted_recipe.content)
      expect(page).to have_content("材料名1")
      expect(page).to have_content(100)
      expect(page).to have_content("単位1")
    end
    
    it '管理者にはレシピ編集、レシピ削除のリンクが表示される' do
      sign_in @admin
      visit recipe_path(posted_recipe.id)
      expect(page).to have_content("レシピ編集")
      expect(page).to have_content("レシピ削除")
    end
    
    it '管理者と本人以外にはレシピ編集、レシピ削除のリンクが表示されない' do
      sign_in @gest_user
      visit recipe_path(posted_recipe.id)
      expect(page).to_not have_content("レシピ編集")
      expect(page).to_not have_content("レシピ削除")
    end
    
  end
  
  describe 'レシピ編集' do
    before do
      new_genre = create(:genre, name: '汁もの') 
      create(:category, name: '味噌汁', genre_id: new_genre.id)
      visit edit_recipe_path(posted_recipe.id)
    end
    
    context '正常系' do
      it 'レシピ名フォームが表示され、保存されたレシピ名が入力されている' do
        expect(page).to have_field 'recipe[title]', with: posted_recipe.title
      end
      
      it 'レシピ紹介文フォームが表示され、保存されたレシピ紹介が入力されている' do
        expect(page).to have_field 'recipe[content]', with: posted_recipe.content
      end
      
      it '調理時間選択フォームが表示され、保存された調理時間が選択されている' do
        expect(page).to have_field 'recipe[total_time]', with: posted_recipe.total_time
      end
      
      it 'ジャンル選択フォームが表示され、カテゴリーidに紐づくジャンルが選択されている' do
        expect(page).to have_field 'recipe[genre_id]', with: posted_recipe.category.genre.id
      end
      
      it 'ジャンル選択フォームが表示され、保存されたジャンルが選択されている' do
        expect(page).to have_field 'recipe[category_id]', with: posted_recipe.category_id
      end
      
      it 'レシピが編集できる' do
        fill_in 'recipe[title]', with: "recipe_title2"
        fill_in 'recipe[content]', with: "recipe_content2"
        select '2時間', from: 'recipe[total_time]'
        select '汁もの', from: 'recipe[genre_id]', visible: false
        select '味噌汁', from: 'recipe[category_id]', visible: false, disabled: false
        click_link "材料の追加"
        page.all(".ingredient-name")[1].set("材料名2")
        page.all(".ingredient-quantity")[1].set(200)
        click_link "作り方の追加"
        page.all(".step-content")[1].set("作り方2")
        find('label[for=recipe_is_open_false]').click 
        click_button 'レシピを投稿する'
        visit recipe_path(posted_recipe.id)
        expect(page).to have_content("recipe_title2")
        expect(page).to have_content("recipe_content2")
        expect(page).to have_content(jp_time_date(posted_recipe.updated_at))
        expect(page).to have_content("2時間")
        expect(page).to have_content("汁もの")
        expect(page).to have_content("味噌汁")
        expect(page).to have_content("材料名1")
        expect(page).to have_content("材料名2")
        expect(page).to have_content(100)
        expect(page).to have_content(200)
        expect(page).to have_content("作り方1")
        expect(page).to have_content("作り方2")
      end
    end
    
    context '異常系' do
      
      it "レシピ名か、レシピ紹介、調理時間が未選択であると送信できず入力するように促される" do
        fill_in 'recipe[title]', with: nil
        fill_in 'recipe[content]', with: nil
        select '汁もの', from: 'recipe[genre_id]', visible: false
        select '味噌汁', from: 'recipe[category_id]', visible: false, disabled: false
        click_link "材料の追加"
        page.all(".ingredient-name")[1].set("材料名2")
        page.all(".ingredient-quantity")[1].set(200)
        click_link "作り方の追加"
        page.all(".step-content")[1].set("作り方2")
        find('label[for=recipe_is_open_false]').click 
        click_button 'レシピを投稿する'
        expect(page).to have_current_path(edit_recipe_path(posted_recipe.id))
      end
      
      it '材料名と材料の分量が未入力だと、レシピを更新できず、エラーメッセージが表示される' do
        find(".ingredient-name").set(nil)
        find(".ingredient-quantity").set(nil)
        click_button 'レシピを投稿する'
        expect(page).to have_content("編集に失敗しました")
        expect(page).to have_content("材料名 が入力されていません。")
        expect(page).to have_content("分量 が入力されていません。")
      end
      
      it '作り方の詳細が未入力だと、レシピを更新できず、エラーメッセージが表示される' do
        find(".step-content").set(nil)
        click_button 'レシピを投稿する'
        expect(page).to have_content("編集に失敗しました")
        expect(page).to have_content("作り方の詳細 が入力されていません。")
      end
      
      
      it "他の方のレシピは編集不可" do
        sign_in @gest_user
        visit edit_recipe_path(posted_recipe.id)
        expect(current_path).to eq root_path
        expect(page).to have_content("他の会員のレシピの更新、削除はできません")
      end
    end
  end
  
  describe 'レシピ削除' do
    context '正常系' do
      it 'レシピデータを削除出来る' do
        visit recipe_path(posted_recipe.id)
        expect(page).to have_content("レシピ削除")
        click_link "レシピ削除"
        alert = page.driver.browser.switch_to.alert
        alert.accept
        expect(current_path).to eq user_path(posted_recipe.user_id)
        # posted_recipe を reload した際に ActiveRecord::RecordNotFound エラーが発生することを期待する
        expect{ posted_recipe.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
  
  describe 'レシピ検索' do
    context '正常系' do
      before do
        visit recipes_path
      end
      it 'レシピ名で検索が出来る' do
        fill_in 'search', with: posted_recipe.title
        find('button').click 
        expect(page).to have_content(posted_recipe.title)
      end
     
      it 'レシピの材料で検索出来る' do
        fill_in 'search', with: posted_recipe.recipe_ingredients.first.name
        find('button').click 
        expect(page).to have_content(posted_recipe.title)
      end
     
      it 'レシピの作り方で検索出来る' do
        fill_in 'search', with: posted_recipe.recipe_steps.first.content
        find('button').click 
        expect(page).to have_content(posted_recipe.title)
      end
      
      it '合致するものがない場合は表示されない' do
        fill_in 'search', with: 'テスト'
        find('button').click 
        expect(page).to_not have_content(posted_recipe.title)
      end
      
      it '時間での絞り込みと併用できる' do
        find('.time-btn').click
        click_link "3時間以内"
        fill_in 'search', with: posted_recipe.title
        find('button').click 
        expect(page).to have_content(posted_recipe.title)
      end
      
      it '時間での絞り込み時、レシピ名と一致しても絞り込んだ時間の条件が合わなければ表示されない' do
        find('.time-btn').click
        click_link "2時間以内"
        fill_in 'search', with: posted_recipe.title
        find('button').click 
        expect(page).to_not have_content(posted_recipe.title)
      end
    end
    
  end
end