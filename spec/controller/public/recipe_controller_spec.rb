require 'rails_helper'

describe Public::RecipesController, type: :controller do
  before do
    @user = create(:user)
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
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
    
  end
end