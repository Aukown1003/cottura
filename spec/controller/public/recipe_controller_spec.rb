require 'rails_helper'

describe Public::RecipesController, type: :controller do
  before do
    @user = create(:user)
    @other_user = create(:user)
    @gest_user = create(:user, email: 'guest@example.com')
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
    @genre = create(:genre)
  end
  let(:new_title) { 'Uptade Recipe Title' }
  
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
    let!(:genre) { create(:genre) }
    let!(:category) { create(:category, genre_id: genre.id) }
    
    before do
      session[:category_id] = category.id
      get :index
    end
    
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
    
    context "カテゴリでフィルタリングしたとき" do
      it "@categoriesには指定したカテゴリのみが含まれる" do
        expect(assigns(:categories)).to eq([category])
      end
    end
    
    context "時間でフィルタリングしたとき" do
      let(:category) { create(:category, genre_id: @genre.id) }
      let(:unit) { create(:unit) }
      let(:recipe1) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 1.hour.ago, total_time: "30") }
      let(:recipe2) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 4.hours.ago, total_time: "120") }
      let(:recipe3) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 5.hours.ago, total_time: "90") }
      
      before do
        recipes = [recipe1, recipe2, recipe3]
        recipes.each do |recipe|
          recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
          recipe.recipe_steps.build(attributes_for(:recipe_step))
          recipe.save
        end
        session[:search_time] = "90"
        get :index
      end
    
      it "@recipesには調理時間が選択した時間以下レシピのみ含まれる" do
        expect(assigns(:recipes)).to eq([recipe1, recipe3])
      end
    end
  end
  
  describe 'GET #show' do
    let(:category) { create(:category, genre_id: @genre.id) }
    let(:unit) { create(:unit) }
    let(:recipe) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 1.hour.ago) }
    let(:other_user_recipe) { build(:recipe, user_id: @other_user.id, category_id: category.id, updated_at: 2.hour.ago) }
    
    before do
      recipes = [recipe, other_user_recipe]
      recipes.each do |recipe|
        recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
        recipe.recipe_steps.build(attributes_for(:recipe_step))
        recipe.save
      end
      get :show, params: { id: recipe.id }
    end
    
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
    
    
    context '未ログイン時' do
      before { sign_out @user }
      
      it "レシピ詳細のビューが正しく表示されている" do
        expect(response).to render_template :show
      end
    end
  end
  
  describe 'POST #create' do
    let(:category) { create(:category, genre_id: @genre.id) }
    let(:unit) { create(:unit) }
    let(:recipe_params) do
      recipe = build(:recipe, user_id: @user.id, category_id: category.id)
      recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
      recipe.recipe_steps.build(attributes_for(:recipe_step))
      recipe.attributes.merge(
        recipe_ingredients_attributes: recipe.recipe_ingredients.first.attributes,
        recipe_steps_attributes: recipe.recipe_steps.first.attributes
      )
    end
    context "投稿失敗時" do
      it "投稿したレシピが保存できる" do
        expect{post :create, params:{ recipe: recipe_params }}.to change(Recipe, :count).by(1)
      end
      
       it "保存後マイページに移動しメッセージが出る" do
        expect{post :create, params:{ recipe: recipe_params }}.to change(Recipe, :count).by(1)
        expect(response).to redirect_to user_path(Recipe.first.user.id)
        expect(flash[:notice]).to eq 'レシピを編集しました'
      end
    end
    
    context "投稿失敗時" do
      it "未入力の部分があると保存できない" do
        recipe_params["title"] = nil
        expect{post :create, params:{ recipe: recipe_params }}.not_to change(Recipe, :count)
      end
      
      it "投稿画面に移動する" do
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
      end
      
      it "レシピが保存出来ない" do
        expect{post :create, params:{ recipe: recipe_params }}.not_to change(Recipe, :count)
      end
      
      it "レシピ投稿ページに移動し、エラーメッセージが出る" do
        post :create, params:{ recipe: recipe_params }
        expect(response).to redirect_to(new_recipe_path)
        expect(flash[:alert]).to eq 'ゲストユーザーはレシピを公開することは出来ません'
      end
    end
  end
    
  describe 'GET #edit' do
    let(:category) { create(:category, genre_id: @genre.id) }
    let(:unit) { create(:unit) }
    let(:recipe) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 1.hour.ago) }
    let(:other_user_recipe) { build(:recipe, user_id: @other_user.id, category_id: category.id, updated_at: 2.hour.ago) }
    
    before do
      recipes = [recipe, other_user_recipe]
      recipes.each do |recipe|
        recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
        recipe.recipe_steps.build(attributes_for(:recipe_step))
        recipe.save
      end
      get :edit, params: { id: recipe.id }
    end
    
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
    
    context '違うユーザーのレシピを編集しようとした際' do
      it 'トップページに移動しエラーメッセージが出る' do
        get :edit, params: { id: other_user_recipe.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq '他の会員のレシピの更新、削除はできません。'
      end
    end
    
    context '未ログイン時' do
      before { sign_out @user }
      
      it "トップページに移動しエラーメッセージが出る" do
        get :edit, params: { id: recipe.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq '未ログイン時、レシピの更新、削除はできません。'
      end
    end
    
  end
  
  describe 'PATCH #update' do
    let(:category) { create(:category, genre_id: @genre.id) }
    let(:unit) { create(:unit) }
    let(:recipe) { build(:recipe, user_id: @user.id, category_id: category.id) }
    let(:gest_user_create_recipe) { build(:recipe, user_id: @gest_user.id, category_id: category.id, is_open: false) }
    
    before do
      recipes = [recipe, gest_user_create_recipe]
      recipes.each do |recipe|
        recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
        recipe.recipe_steps.build(attributes_for(:recipe_step))
        recipe.save
      end
    end
    
    context '編集に成功した場合' do
      before do
        patch :update, params: { id: recipe.id, recipe: { title: new_title } }
      end
      
      it 'レシピ名が編集したものに変わっている' do
        expect(recipe.reload.title).to eq new_title
      end
      
      it '編集後にマイページに移動しメッセージが出る' do
        expect(response).to redirect_to user_path(@user.id)
        expect(flash[:notice]).to eq 'レシピを編集しました'
      end
    end
    
    context '編集に失敗した場合' do
      before do
        patch :update, params: { id: recipe.id, recipe: { title: nil } }
      end
      
      it 'レシピ名が編集前に戻っている' do
        expect(recipe.reload.title).to eq recipe.title
      end
      
      it '編集画面に移動し、エラーメッセージが出る' do
        expect(response).to render_template :edit
        expect(flash[:alert]).to eq '編集に失敗しました'
      end
    end
    
    context 'ゲストユーザーの場合' do
      before do
        sign_out @user
        sign_in @gest_user
      end
      
      it 'レシピ名が編集したものに変わっている' do
        patch :update, params: { id: gest_user_create_recipe.id, recipe: { title: new_title } }
        expect(gest_user_create_recipe.reload.title).to eq new_title
      end
      
      it '編集後にマイページに移動しメッセージが出る' do
        patch :update, params: { id: gest_user_create_recipe.id, recipe: { title: new_title } }
        expect(response).to redirect_to user_path(@gest_user.id)
        expect(flash[:notice]).to eq 'レシピを編集しました'
      end
      
      it 'レシピ名が空欄で保存しようとした際、レシピ名が編集前に戻っている' do
        patch :update, params: { id: gest_user_create_recipe.id, recipe: { title: nil } }
        expect(gest_user_create_recipe.reload.title).to eq gest_user_create_recipe.title
      end
      
      it 'レシピ名が空欄で保存しようとした際、編集画面に移動し、エラーメッセージが出る' do
        patch :update, params: { id: gest_user_create_recipe.id, recipe: { title: nil } }
        expect(response).to render_template :edit
        expect(flash[:alert]).to eq '編集に失敗しました'
      end
      
      it "レシピを「公開」で更新した際、トップページに移動し、エラーメッセージが出る" do
        patch :update, params: { id: gest_user_create_recipe.id, recipe: { is_open: true } }
        expect(response).to redirect_to(new_recipe_path)
        expect(flash[:alert]).to eq 'ゲストユーザーはレシピを公開することは出来ません'
      end
    end
    
    context '未ログイン時' do
      before { sign_out @user }
      
      it "トップページに移動しエラーメッセージが出る" do
        get :update, params: { id: recipe.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq '未ログイン時、レシピの更新、削除はできません。'
      end
    end
    
  end
  
  
end