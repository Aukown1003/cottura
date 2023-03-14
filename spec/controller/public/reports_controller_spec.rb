require 'rails_helper'

describe Public::ReportsController, type: :controller do
  before do
    @user = create(:user)
    @recipe_user = create(:user)
    @genre = create(:genre)
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
    # save_recipe_with_ingredient_and_step(recipe, unit)
  end
  let(:category) { create(:category, genre_id: @genre.id) }
  # let(:unit) { create(:unit) }
  # let!(:recipe) { build(:recipe, user_id: @recipe_user.id, category_id: category.id) }
  let!(:recipe) { create(:recipe, :with_recipe_ingredient, :with_recipe_step, user_id: @user.id, category_id: category.id) }
  
  
  describe 'GET #new' do
    before { get :new, params:{ id: recipe.id }}
    
    context '正常系' do
      it 'レポート投稿用のビューが正しく表示されている' do
        expect(response).to render_template :new
      end
      
      it 'レポートの新しいインスタンス変数 @report が作成されている' do
        expect(assigns(:report)).to be_a_new(Report)
      end
      
      it 'レシピが、インスタンス変数 @recipe に割り当てられている' do
        expect(assigns(:recipe)).to eq recipe
      end
    end
  end
  
  describe 'POST #create' do
    let!(:report_params) { build(:report, recipe_id: recipe.id, user_id: @user.id) }
    context "正常系" do
      it 'レポートが保存され、トップ画面に移動し、メッセージが表示される' do
        expect{post :create, params:{ report: report_params.attributes, recipe_id: recipe.id}}.to change(Report, :count).by(1)
        expect_redirect_to_with_notice(root_path(recipe.id), '報告を行いました')
      end
    end
    
    context "異常系" do
      it '投稿に失敗した際は、レポートが保存されずレポート投稿に戻り、エラーメッセージが表示される' do
        report_params.content = nil
        expect{post :create, params:{ report: report_params.attributes, recipe_id: recipe.id}}.not_to change(Report, :count)
        expect_render_to_with_alert(:new, '報告に失敗しました')
      end
    end
  end
end