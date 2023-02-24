require 'rails_helper'

describe Admin::ReportsController, type: :controller do
  before do
    @admin = create(:admin)
    @report_user = create(:user)
    sign_in @admin
    save_recipe_with_ingredient_and_step(recipe, unit)
  end
  let(:user) { create(:user) }
  let(:genre) { create(:genre) }
  let(:category) { create(:category, genre_id: genre.id) }
  let(:unit) { create(:unit) }
  let!(:recipe) { build(:recipe, user_id: user.id, category_id: category.id) }
  let!(:report) {create(:report, user_id: @report_user.id, recipe_id: recipe.id)}
  
  describe "GET #show" do
    before do
      get :show, params: {id: report.id}
    end
    context '正常系' do
      it 'ユーザ詳細のビューが正しく表示されている' do
        expect(response).to render_template :show
      end
      
      it 'レポートの詳細が、インスタンス変数 @report に割り当てられている' do
        expect(assigns(:report)).to eq(report)
      end
    end
  end
  
end
