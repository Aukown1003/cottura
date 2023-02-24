require 'rails_helper'

describe Admin::CategoriesController, type: :controller do
  before do
    @admin = create(:admin)
    sign_in @admin
  end
  let(:genre) { create(:genre) }
  let(:category) { create(:category, genre_id: genre.id) }
  
  describe "POST #create" do
    context '正常系' do
      let(:params_data) { build(:category, genre_id: genre.id) }
      it 'カテゴリーが保存でき、ジャンル、カテゴリー一覧に移動し、メッセージが表示される' do
        expect{post :create, params:{ category: params_data.attributes }}.to change(Category, :count).by(1)
        expect_redirect_to_with_notice(admin_genres_path, 'カテゴリーを作成しました')
      end
    end
    
    context '異常系' do
      let(:params_data) { build(:category, genre_id: genre.id, name: nil) }
      it 'カテゴリーが保存できず、ジャンル、カテゴリー一覧に移動し、エラーメッセージが表示される' do
        expect{post :create, params:{ category: params_data.attributes }}.to_not change(Category, :count)
        expect_redirect_to_with_alert(admin_genres_path, 'カテゴリーの作成に失敗しました')
      end
    end
  end
  
  describe "GET #edit" do
    before do
      get :edit, params: {id: category.id}
    end
    
    context '正常系' do
      it 'カテゴリー編集のビューが正しく表示されている' do
        expect(response).to render_template :edit
      end
      
      it "編集するカテゴリーが、インスタンス変数 @category に割り当てられている" do
        expect(assigns(:category)).to eq(category)
      end
      
      it "全てジャンルが、インスタンス変数 @genres に割り当てられている" do
        expect(assigns(:genres)).to eq(Genre.all)
      end
    end
  end
end