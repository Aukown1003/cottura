require 'rails_helper'

describe Public::RecipesController, type: :controller do
  before do
    @user = create(:user)
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
    @genre = create(:genre)
  end
  
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
      let(:recipe2) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 4.hours.ago, total_time: "90") }
      let(:recipe3) { build(:recipe, user_id: @user.id, category_id: category.id, updated_at: 5.hours.ago, total_time: "120") }
    
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
        expect(assigns(:recipes)).to eq([recipe1, recipe2])
      end
    end

  end
end