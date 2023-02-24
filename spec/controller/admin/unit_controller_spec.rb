require 'rails_helper'

describe Admin::UnitsController, type: :controller do
  before do
    @admin = create(:admin)
    sign_in @admin
  end
  let(:unit) { create(:unit) }
  
  describe "GET #index" do
    before { get :index }
    context 'ビュー、変数の割当確認' do
      it "ユーザ一覧のビューが正しく表示されている" do
        expect(response).to render_template :index
      end
      
      it "全て単位が、インスタンス変数 @units に割り当てられている" do
        expect(assigns(:units)).to eq(Unit.all)
      end
      
      it "新しい単位が、インスタンス変数 @unit に割り当てられている" do
        expect(assigns(:unit)).to be_a_new(Unit)
      end
    end
  end
  
  describe "POST #create" do
    context '正常系' do
      let(:params_data) { build(:unit) }
      it '単位が保存でき、単位一覧に移動し、メッセージが表示される' do
        expect{post :create, params:{ unit: params_data.attributes }}.to change(Unit, :count).by(1)
        expect_redirect_to_with_notice(admin_units_path, '単位を作成しました')
      end
    end
    
    context '異常系' do
      let(:params_data) { build(:unit, name: nil) }
      it '単位が保存できず、単位一覧に移動し、エラーメッセージが表示される' do
        expect{post :create, params:{ unit: params_data.attributes }}.to_not change(Unit, :count)
        expect_redirect_to_with_alert(admin_units_path, '単位の作成に失敗しました')
      end
    end
  end
  
  describe "GET #edit" do
    before do
      get :edit, params: {id: unit.id}
    end
    
    context '正常系' do
      it '単位編集のビューが正しく表示されている' do
        expect(response).to render_template :edit
      end
      
      it "単位が、インスタンス変数 @unit に割り当てられている" do
        expect(assigns(:unit)).to eq(unit)
      end
    end
  end
  
  describe "PATCH #update" do
    context '正常系' do
      it '編集したユニット名にレコードが変更され、単位、カテゴリー一覧に移動し、メッセージが表示される' do
        patch :update, params: {id: unit.id, unit:{name: 'new_unit_name'}}
        expect(unit.reload.name).to eq('new_unit_name')
        expect_redirect_to_with_notice(admin_units_path, '単位を変更しました')
      end
    end
    
    context '異常系' do
      it '編集前のユニット名に戻り、単位編集画面に移動し、エラーメッセージが表示される' do
        patch :update, params: {id: unit.id, unit:{name: nil}}
        expect(unit.reload.name).to eq(unit.name)
        expect_redirect_to_with_alert(edit_admin_unit_path, '単位の変更に失敗しました')
      end
    end
  end

  describe "DELETE #destroy" do
    context '正常系' do
      it '単位が削除出来、単位一覧に移動し、メッセージが表示される' do
        unit_id = unit.id
        expect{delete :destroy, params: { id: unit_id }}.to change(Unit, :count).by(-1)
        expect_redirect_to_with_notice(admin_units_path, '単位を削除しました')
      end
    end
  end
end