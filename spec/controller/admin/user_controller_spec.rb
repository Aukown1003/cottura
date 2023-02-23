require 'rails_helper'

describe Admin::UsersController, type: :controller do
  before do
    @admin = create(:admin)
    @user = create(:user)
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @admin
  end
  
  describe "GET #index" do
    before { get :index }
    context '正常系' do
      
      it "ユーザ一覧のビューが正しく表示されている" do
        expect(response).to render_template :index
      end
      
      it "ユーザー全てが、インスタンス変数 @users に割り当てられている" do
        expect(assigns(:users)).to eq(User.all)
      end
    end
    
    context '異常系' do
      before do 
        sign_out @admin
        sign_in @user
        get :index
      end
      
      it 'ユーザーがアクセスしようとすると、管理者のログイン画面に移動し、エラーメッセージが表示される' do
        expect_redirect_to_with_alert(new_admin_session_path, 'ログインもしくはアカウント登録してください。')
      end
      
      it '未ログインでアクセスしようとすると、管理者のログイン画面に移動し、エラーメッセージが表示される' do
        sign_out @user
        get :index
        expect_redirect_to_with_alert(new_admin_session_path, 'ログインもしくはアカウント登録してください。')
      end
    end
  end
  
end
