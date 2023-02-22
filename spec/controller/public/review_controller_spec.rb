require 'rails_helper'

describe Public::ReviewsController, type: :controller do
  before do
    @user = create(:user)
    @gest_user = create(:user, email: 'guest@example.com')
    @recipe_user = create(:user)
    @genre = create(:genre)
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
    save_recipe_with_ingredient_and_step(recipe, unit)
  end
  let(:category) { create(:category, genre_id: @genre.id) }
  let(:unit) { create(:unit) }
  let!(:recipe) { build(:recipe, user_id: @recipe_user.id, category_id: category.id) }
  
  describe 'POST #create' do
    let!(:review_params) { build(:review, recipe_id: recipe.id, user_id: @user.id) }
    
    context "正常系" do
      it '投稿したレビューが保存され、レシピ画面に移動し、メッセージが表示される' do
        expect{post :create, params:{ review: review_params.attributes, recipe_id: recipe.id}}.to change(Review, :count).by(1)
        expect_redirect_to_with_notice(recipe_path(recipe.id), 'レビューを投稿しました。')
      end
    end
    
    context "異常系" do
      it '投稿に失敗した際は、レビューが保存されずレシピ画面に移動し、エラーメッセージが表示される' do
        review_params.content = nil
        expect{post :create, params:{ review: review_params.attributes, recipe_id: recipe.id}}.not_to change(Review, :count)
        expect_redirect_to_with_alert(recipe_path(recipe.id), 'レビューの投稿に失敗しました。未入力の項目があります。')
      end
      
      it '未ログイン時にレビューを投稿しようとすると、保存されずレシピ一覧に移動し、エラーメッセージが表示される' do
        sign_out @user
        expect{post :create, params:{ review: review_params.attributes, recipe_id: recipe.id}}.not_to change(Review, :count)
        expect_redirect_to_with_alert(recipes_path, '未ログイン時、レビューを投稿、削除することは出来ません')
      end
      
      it 'ゲストユーザーがレビューを投稿しようとすると、保存されずレシピ一覧に移動し、エラーメッセージが表示される' do
        sign_out @user
        sign_in @gest_user
        review_params.user_id = @gest_user.id
        expect{post :create, params:{ review: review_params.attributes, recipe_id: recipe.id}}.not_to change(Review, :count)
        expect_redirect_to_with_alert(recipes_path, 'ゲストユーザーはレビューを投稿、削除することは出来ません')
      end
      
      it '自分自身のレシピにレビューを投稿しようとすると、保存されずレシピ一覧に移動し、エラーメッセージが表示される' do
        recipe.user_id = @user.id
        recipe.save
        expect{post :create, params:{ review: review_params.attributes, recipe_id: recipe.id}}.not_to change(Review, :count)
        expect_redirect_to_with_alert(recipes_path, '自身のレシピにレビューを投稿、削除することは出来ません')
      end
    end
  end
  
  describe 'Delete #destroy' do
    let!(:review) { create(:review, recipe_id: recipe.id, user_id: @user.id) }
    before do
      request.env['HTTP_REFERER'] = recipe_path(recipe.id)
    end
    
    context "正常系" do
      it 'レビューが削除され、レシピ詳細ページに戻り、メッセージが表示される' do
        expect {delete :destroy, params: { id: review.id, recipe_id: recipe.id }}.to change(Review, :count).by(-1)
        expect_redirect_to_with_notice(recipe_path(recipe.id), 'レビューを削除しました。')
      end
    end
    
    context "異常系" do
      before do
        review.content = nil
      end
      
      it '未ログイン時にレビューを削除しようとすると、保存されずレシピ一覧に移動し、エラーメッセージが表示される' do
        sign_out @user
        delete :destroy, params: { id: review.id, recipe_id: recipe.id }
        expect_redirect_to_with_alert(recipes_path, '未ログイン時、レビューを投稿、削除することは出来ません')
      end
      
      it 'ゲストユーザーがレビューを削除しようとすると、保存されずレシピ一覧に移動し、エラーメッセージが表示される' do
        sign_out @user
        sign_in @gest_user
        delete :destroy, params: { id: review.id, recipe_id: recipe.id }
        expect_redirect_to_with_alert(recipes_path, 'ゲストユーザーはレビューを投稿、削除することは出来ません')
      end
      
      it '自分自身のレシピのレビューを削除しようとすると、保存されずレシピ一覧に移動し、エラーメッセージが表示される' do
        recipe.user_id = @user.id
        recipe.save
        delete :destroy, params: { id: review.id, recipe_id: recipe.id }
        expect_redirect_to_with_alert(recipes_path, '自身のレシピにレビューを投稿、削除することは出来ません')
      end
    end
  end
end