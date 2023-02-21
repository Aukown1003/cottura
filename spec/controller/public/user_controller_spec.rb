require 'rails_helper'

describe Public::UsersController, type: :controller do
  before do
    @user = create(:user)
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
  end
  let(:new_name) { 'New Name' }
  let(:new_content) { 'New Hello' }
  
  describe 'GET #show' do
    before { get :show, params: { id: @user.id } }
    
    it 'ユーザー詳細用のビューが正しく表示されている' do
      expect(response).to render_template :show
    end
    
    it 'ユーザーが、コントローラーのインスタンス変数 @user に割り当てられている' do
      expect(assigns(:user)).to eq @user
    end
  end
    
  describe 'GET #edit' do
    before { get :edit, params: { id: @user.id } }
    
    it 'ユーザー編集用のビューが正しく表示されている' do
      expect(response).to render_template :edit
    end

    it '編集するユーザーが、コントローラーのインスタンス変数 @user に割り当てられている' do
      expect(assigns(:user)).to eq @user
    end
    
    context '他のユーザーにアクアスした場合' do
      before do
        @other_user = create(:user)
      end
      
      it 'トップページに移動しエラーメッセージが表示される' do
        get :edit, params: { id: @other_user.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq 'ゲストユーザーや他の会員の情報の更新はできません'
      end
    end
    
    context 'ゲストユーザーの場合' do
      it 'アクセス時トップページに移動しエラーメッセージが表示される' do
        user = create(:user, email: 'guest@example.com')
        request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
        get :edit, params: { id: user.id }
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq 'ゲストユーザーや他の会員の情報の更新はできません'
      end
    end
    
    context '未ログイン時' do
      before { sign_out @user }

      it 'アクセス時トップページに移動しエラーメッセージが表示される' do
        get :edit, params: { id: @user.id }
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq '未ログイン時、ユーザーの編集は行なえません'
      end
    end
  end
  
  describe 'PATCH #update' do
    context '編集に成功した場合' do
      before { patch :update, params: { id: @user.id, user: { name: new_name } } }
      
      it 'ユーザー名が編集したものに変わっている' do
        expect(@user.reload.name).to eq new_name
      end
      
      it '自己紹介が編集したものに変わっている' do
        patch :update, params: { id: @user.id, user: { content: new_content } }
        expect(@user.reload.content).to eq new_content
      end
      
      it '編集後にマイページに移動しメッセージが表示される' do
        expect(response).to redirect_to user_path(@user.id)
        expect(flash[:notice]).to eq 'ユーザー情報を編集しました。'
      end
    end
    
    context '編集に失敗した場合' do
      before { patch :update, params: { id: @user.id, user: { name: '' } } }
      
      it 'ユーザー名が編集前に戻っている' do
        expect(@user.reload.name).not_to eq ''
      end
      
      it '自己紹介が編集前に戻っている' do
        patch :update, params: { id: @user.id, user: { content: '' } }
        expect(@user.reload.content).not_to eq ''
      end
      
      it '編集画面に移動し、エラーメッセージが表示される' do
        expect(response).to render_template :edit
        expect(flash[:alert]).to eq '編集に失敗しました'
      end
    end
  end
  
  describe "PATCH #withdrawal" do
    before { patch :withdrawal, params: { user_id: @user.id } }
    
    it "ステータスが退会に変わっているセッションが削除されているか" do
      expect(@user.reload.is_active).to be_falsey
    end
    
    it "ユーザー情報の入ったセッションが削除されている" do
      expect(session.to_hash["warden.user.user.key"]).to eq nil 
    end
    
    it "トップページに移動しメッセージが表示される" do
      expect(response).to redirect_to root_path
      expect(flash[:notice]).to eq '退会が完了しました。'
    end
  end
end