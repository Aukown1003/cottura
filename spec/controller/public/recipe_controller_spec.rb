require 'rails_helper'

describe Public::RecipesController, type: :controller do
  before do
    @user = create(:user)
    @other_user = create(:user)
    @gest_user = create(:user, email: 'guest@example.com')
    @genre = create(:genre)
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
  end
  let(:new_title) { 'Uptade Recipe Title' }
  let(:category) { create(:category, genre_id: @genre.id) }
  let(:unit) { create(:unit) }
  let!(:recipe) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 1.hour.ago) }
  
  describe 'GET #new' do
    before { get :new }
    
    it '新規レシピ投稿用のビューが正しく表示されている' do
      expect(response).to render_template :new
    end
    
    it 'レシピが、インスタンス変数 @recipe に割り当てられている' do
      expect(assigns(:recipe)).to be_a_new(Recipe)
    end
    
    it 'ジャンルの全データが、インスタンス変数 @genres に割り当てられている' do
      expect(assigns(:genres)).to eq(Genre.all)
    end
    
    it 'カテゴリーの全データが、インスタンス変数 @categories に割り当てられている' do
      expect(assigns(:categories)).to eq(Category.all)
    end
  end
  
  describe "GET #index" do
    before do
      session[:category_id] = category.id
      get :index
    end
    
    context "正常系" do
      it "レシピ一覧のビューが正しく表示されている" do
        expect(response).to render_template :index
      end
      
      it "レシピが、インスタンス変数 @recipe に割り当てられている" do
        expect(assigns(:recipes)).to_not be_nil
      end
      
      it "カテゴリーが、インスタンス変数 @categories に割り当てられている" do
        expect(assigns(:categories)).to_not be_nil
      end
      
      it "ジャンルが、インスタンス変数 @genres　に割り当てられている" do
        expect(assigns(:genres)).to_not be_nil
      end
    end
    
    context "カテゴリでフィルタリングしたとき" do
      it "@categoriesには指定したカテゴリのみが含まれる" do
        expect(assigns(:categories)).to eq([category])
      end
    end
    
    context "時間でフィルタリングしたとき" do
      let(:recipe1) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 1.hour.ago, total_time: "30") }
      let(:recipe2) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 4.hours.ago, total_time: "120") }
      let(:recipe3) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 5.hours.ago, total_time: "90") }
      
      before do
        recipes = [recipe1, recipe2, recipe3]
        recipes.each { |recipe| save_recipe_with_ingredient_and_step(recipe, unit) }
        session[:search_time] = "90"
        get :index
      end
    
      it "@recipesには調理時間が選択した時間以下レシピのみ含まれる" do
        expect(assigns(:recipes)).to eq([recipe1, recipe3])
      end
    end
  end
  
  describe 'GET #show' do
    let(:other_user_recipe) { build(:recipe, user_id: @other_user.id, category_id: category.id, updated_at: 2.hour.ago) }
    
    before do
      recipes = [recipe, other_user_recipe]
      recipes.each { |recipe| save_recipe_with_ingredient_and_step(recipe, unit) }
      get :show, params: { id: recipe.id }
    end
    
    context '正常系' do
      it "レシピ詳細のビューが正しく表示されている" do
        expect(response).to render_template :show
      end
      
      it 'レシピが、インスタンス変数 @recipe に割り当てられている' do
        expect(assigns(:recipe)).to eq recipe
      end
      
      it 'レシピ他のユーザーの場合でも、インスタンス変数 @recipe に割り当てられている' do
        get :show, params: { id: other_user_recipe.id }
        expect(assigns(:recipe)).to eq other_user_recipe
      end
      
      it '新しいレビューが、インスタンス変数 @review に割り当てられている' do
        expect(assigns(:review)).to be_a_new Review
      end
    end
    
    context '存在しないレシピにアクセスしようとした際' do
      it "トップページに移動しエラーメッセージが表示される" do
        get :show, params: { id: 0 }
        expect_redirect_to_with_alert(root_path, "レシピが見つかりませんでした")
      end
    end
    
    context '未ログイン時' do
      before { sign_out @user }
      
      it "レシピ詳細のビューが正しく表示されている" do
        expect(response).to render_template :show
      end
    end
  end
  
  describe 'POST #create' do
    let(:recipe_params) do
      recipe = build(:recipe, user_id: @user.id, category_id: category.id)
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.attributes.merge(
        recipe_ingredients_attributes: recipe.recipe_ingredients.first.attributes,
        recipe_steps_attributes: recipe.recipe_steps.first.attributes
      )
    end
    
    context "正常系" do
      it "投稿したレシピが保存でき、マイページに移動しメッセージが表示される" do
        expect{post :create, params:{ recipe: recipe_params }}.to change(Recipe, :count).by(1)
        expect_redirect_to_with_notice(user_path(@user.id), 'レシピを投稿しました')
      end
    end
    
    context "異常系" do
      it "未入力の部分があると保存できず、投稿画面に移動する" do
        recipe_params["title"] = nil
        expect{post :create, params:{ recipe: recipe_params }}.not_to change(Recipe, :count)
        expect(response).to render_template :new
      end
    end
    
    context "ゲストユーザーで、レシピの公開状況が「公開」の場合" do
      let(:recipe_params) do
        recipe = recipe = build(:recipe, user_id: @gest_user.id, category_id: category.id, is_open: true)
        recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
        recipe.recipe_steps.build(attributes_for(:recipe_step))
        recipe.attributes.merge(
          recipe_ingredients_attributes: recipe.recipe_ingredients.first.attributes,
          recipe_steps_attributes: recipe.recipe_steps.first.attributes
        )
      end
      
      before do
        sign_out @user
        sign_in @gest_user
        post :create, params:{ recipe: recipe_params }
      end
      
      it "レシピが保存出来ず、レシピ投稿ページに移動し、エラーメッセージが表示される" do
        expect_redirect_to_with_alert(new_recipe_path, 'ゲストユーザーはレシピを公開することは出来ません')
      end
    end
  end
    
  describe 'GET #edit' do
    let(:other_user_recipe) { build(:recipe, user_id: @other_user.id, category_id: category.id, updated_at: 2.hour.ago) }
    
    before do
      recipes = [recipe, other_user_recipe]
      recipes.each { |recipe| save_recipe_with_ingredient_and_step(recipe, unit) }
    end
    
    context '正常系' do
      before { get :edit, params: { id: recipe.id } }
      
      it 'レシピ編集用のビューが正しく表示されている' do
        expect(response).to render_template :edit
      end
      
      it '編集するレシピが、コントローラーのインスタンス変数 @recipe に割り当てられている' do
        expect(assigns(:recipe)).to eq recipe
      end
      
      it 'ジャンルの全データが、インスタンス変数 @genres に割り当てられている' do
        expect(assigns(:genres)).to eq(Genre.all)
      end
      
      it 'レシピのカテゴリーと同じジャンルに属するカテゴリー全てが、インスタンス変数 @categories に割り当てられている' do
        expect(assigns(:categories)).to eq(Category.where(genre_id: recipe.category.genre_id))
      end
    end
    
    context '存在しないレシピを編集しようとした際' do
      it "トップページに移動しエラーメッセージが表示される" do
        get :edit, params: { id: 0 }
        expect_redirect_to_with_alert(root_path, 'レシピが見つかりませんでした')
      end
    end
    
    context '違うユーザーのレシピを編集しようとした際' do
      before { get :edit, params: { id: other_user_recipe.id } }
      
      it 'トップページに移動しエラーメッセージが表示される' do
        expect_redirect_to_with_alert(root_path, '他の会員のレシピの更新、削除はできません。')
      end
    end
    
    context '未ログイン時' do
      before do
        sign_out @user
        get :edit, params: { id: recipe.id }
      end
      
      it "トップページに移動しエラーメッセージが表示される" do
        expect_redirect_to_with_alert(root_path, '未ログイン時、レシピの更新、削除はできません。')
      end
    end
  end
  
  describe 'PATCH #update' do
    let(:gest_user_create_recipe) { build(:recipe, user_id: @gest_user.id, category_id: category.id, is_open: false) }
    
    before do
      recipes = [recipe, gest_user_create_recipe]
      recipes.each { |recipe| save_recipe_with_ingredient_and_step(recipe, unit) }
    end
    
    context '正常系' do
      before do
        patch :update, params: { id: recipe.id, recipe: { title: new_title } }
      end
      
      it 'レシピ名が編集したものに変わり、マイページに移動しメッセージが表示される' do
        expect(recipe.reload.title).to eq new_title
        expect_redirect_to_with_notice(user_path(@user.id), 'レシピを編集しました')
      end
    end
    
    context '異常系' do
      before do
        patch :update, params: { id: recipe.id, recipe: { title: nil } }
      end
      
      it 'レシピ名が編集前に戻り、編集画面に移動し、エラーメッセージが表示される' do
        expect(recipe.reload.title).to eq recipe.title
        expect_render_to_with_alert(:edit,'編集に失敗しました')
      end
    end
    
    context '他のユーザーのレシピを編集しようとした場合' do
      before { patch :update, params: { id: gest_user_create_recipe.id, recipe: { title: new_title } }}
      
      it 'レシピ名が編集前に戻り、編集画面に移動し、エラーメッセージが表示される' do
        expect(recipe.reload.title).not_to eq new_title
        expect_redirect_to_with_alert(root_path, '他の会員のレシピの更新、削除はできません。')
      end
    end
    
    context 'ゲストユーザーで、レシピを「公開」で更新した際' do
      before do
        sign_out @user
        sign_in @gest_user
        patch :update, params: { id: gest_user_create_recipe.id, recipe: { is_open: true } }
      end
      
      it "トップページに移動し、エラーメッセージが表示される" do
        expect_redirect_to_with_alert(new_recipe_path, 'ゲストユーザーはレシピを公開することは出来ません')
      end
    end
    
    context '未ログイン時' do
      before { sign_out @user }
      
      it "トップページに移動しエラーメッセージが表示される" do
        get :update, params: { id: recipe.id }
        expect_redirect_to_with_alert(root_path, '未ログイン時、レシピの更新、削除はできません。')
      end
    end
    
  end
  
  describe 'Delete #destroy' do
    let!(:other_user_recipe) { build(:recipe, user_id: @other_user.id, category_id: category.id, updated_at: 2.hour.ago) }
    
    before do
      recipes = [recipe, other_user_recipe]
      recipes.each { |recipe| save_recipe_with_ingredient_and_step(recipe, unit) }
    end
    
    context "正常系" do
      it "レシピが削除され、マイページに移動しメッセージが表示される" do
        expect {delete :destroy, params: { id: recipe.id }}.to change(Recipe, :count).by(-1)
        expect_redirect_to_with_notice(user_path(recipe.user_id), 'レシピを削除しました')
      end
    end
    
    context "異常系" do
      context "存在しないレシピを削除しようとした場合" do
        it "トップページに移動しエラーメッセージが表示される" do
          delete :destroy, params: { id: 0 }
          expect_redirect_to_with_alert(root_path, 'レシピが見つかりませんでした')
        end
      end
      
      context "他のユーザーのレシピを削除しようとした場合" do
        it 'トップページに移動しエラーメッセージが表示される' do
          delete :destroy, params: { id: other_user_recipe.id }
          expect_redirect_to_with_alert(root_path, '他の会員のレシピの更新、削除はできません。')
        end
      end
      
      context '未ログイン時' do
        before { sign_out @user }
        
        it "トップページに移動しエラーメッセージが表示される" do
          delete :destroy, params: { id: recipe.id }
          expect_redirect_to_with_alert(root_path, '未ログイン時、レシピの更新、削除はできません。')
        end
      end
    end

  end
  
  describe 'GET #search_category' do
    let(:genre2) { create(:genre) }
    let(:genre3) { create(:genre) }
    let!(:category2) { create(:category, genre_id: @genre.id) }
    let!(:category3) { create(:category, genre_id: genre2.id) }
    let!(:category4) { create(:category, genre_id: genre3.id) }
    
    context 'ジャンルを選択した場合' do
      it '選択したジャンルを元にカテゴリーを絞り込み、そのデータが@categoryに代入される' do
        get :search_category, params: { genre_id: @genre.id }, xhr: true
        expect(assigns(:category)).to match_array([category, category2])
      end
    end
    
    context 'ジャンルを選択した場合' do
      it '@categoryに値は存在しない' do
        get :search_category, xhr: true
        expect(assigns(:category)).to be_nil
      end
    end
  end
  
  describe 'GET #select_time_or_category' do
    let(:time) { 80 }
    let!(:category2) { create(:category, genre_id: @genre.id) }
    
    context '時間で絞り込みをかけた場合' do
      it 'セッションに選んだ時間が保存され、レシピ一覧にリダイレクトする' do
        get :select_time_or_category, params: { search_time: time }
        expect(session[:search_time]).to eq(time.to_s)
        expect(response).to redirect_to(recipes_path)
      end
    end
    
    context 'カテゴリーで絞り込みをかけた場合' do
      it 'セッションに選んだカテゴリーが保存され、レシピ一覧にリダイレクトする' do
        get :select_time_or_category, params: { category_id: category.id }
        expect(session[:category_id]).to match_array([ (category.id).to_s ])
        expect(response).to redirect_to(recipes_path)
      end
      
      it 'すでにカテゴリーがあり、さらにカテゴリーを追加した時、セッションに２つのカテゴリーが保存されている' do
        session[:category_id] = [category.id.to_s]
        get :select_time_or_category, params: { category_id: category2.id }
        expect(session[:category_id]).to match_array([ (category.id).to_s, (category2.id).to_s ])
      end
      
      it '同じカテゴリを追加した時、重複しない' do
        session[:category_id] = [category.id.to_s]
        get :select_time_or_category, params: { category_id: category.id }
        expect(session[:category_id]).to match_array([ (category.id).to_s ])
      end
    end
  end
  
  describe 'Delete #category_id_delete' do
    let(:time) { 80 }
    let!(:category2) { create(:category, genre_id: @genre.id) }
    
    before do
      session[:category_id] = [category.id.to_s]
      session[:search_time] = [ time.to_s ]
    end
    
    context '時間の絞り込みを解除する場合' do
      it 'セッションの中身が削除され、レシピ一覧にリダイレクトする' do
        delete :category_id_delete, params: { destroy_time_id: time }
        expect(session[:search_time]).to be_nil
        expect(response).to redirect_to(recipes_path)
      end
    end
    
    context 'カテゴリの絞り込みを解除する場合' do
      it 'セッションの中身が削除され、レシピ一覧にリダイレクトする' do
        delete :category_id_delete, params: { destroy_category_id: category.id }
        expect(session[:category_id]).to be_empty
        expect(response).to redirect_to(recipes_path)
      end
    end
    
    context '複数カテゴリがある時、一つのカテゴリーの絞り込みを解除する場合' do
      before { session[:category_id] = [ (category.id).to_s, (category2.id).to_s ] }
      
       it '選択したカテゴリーのみ、セッションから削除され、レシピ一覧にリダイレクトする' do
         delete :category_id_delete, params: { destroy_category_id: category2.id }
         expect(session[:category_id]).to match_array([ (category.id).to_s ])
         expect(response).to redirect_to(recipes_path)
       end
     end
  end
  
  describe 'Delete #category_id_all_delete' do
    let(:time) { 80 }
    let!(:category2) { create(:category, genre_id: @genre.id) }
    
    before do
      session[:category_id] = [ (category.id).to_s, (category2.id).to_s ]
      session[:search_time] = [ time.to_s ]
      delete :category_id_all_delete
    end
    
    it '時間とカテゴリーの両方のセッションが削除され、レシピ一覧に移動する' do
      expect(session[:search_time]).to be_nil
      expect(session[:category_id]).to be_nil
      expect(response).to redirect_to(recipes_path)
    end
  end
  
  describe 'GET #recalculation' do
    let(:quantity) { 100 }
    before do
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, quantity: 200, unit_id: unit.id))
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.save
    end
    
    context '正常系' do
      let(:params_data) { { recipe_id: recipe.id, recipe: { recipe.recipe_ingredients.first.id => quantity } } }
       it 'セッションに計算用の係数が保存され、レシピ詳細に戻る' do
         request.env['HTTP_REFERER'] = recipe_path(recipe.id)
         get :recalculation, params: params_data
         expect(response).to redirect_to recipe_path(recipe.id)
         expect(session[:recalculation]).to eq(0.5)
       end
    end
    
    context '異常系、２つ以上の値で再計算しようとした場合' do
      let(:params_data) { { recipe_id: recipe.id, recipe: { recipe.recipe_ingredients.first.id => quantity, "2" => 20 } } }
      
      it 'レシピの詳細に戻り、エラーメッセージが表示される' do
        request.env['HTTP_REFERER'] = recipe_path(recipe.id)
        get :recalculation, params: params_data
        expect(response).to redirect_to recipe_path(recipe.id)
        expect(flash[:alert]).to eq('2つ以上の値で再計算は行なえません')
      end
    end
  end
end