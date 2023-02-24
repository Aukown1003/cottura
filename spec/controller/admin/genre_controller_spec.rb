require 'rails_helper'

describe Admin::GenresController, type: :controller do
  before do
    @admin = create(:admin)
    sign_in @admin
  end
  
  describe "GET #index" do
    before { get :index }
    context 'ビュー、変数の割当確認' do
      it "ユーザ一覧のビューが正しく表示されている" do
        expect(response).to render_template :index
      end
      
      it "全てジャンルが、インスタンス変数 @genres に割り当てられている" do
        expect(assigns(:genres)).to eq(Genre.all)
      end
      
      it "新しいジャンルが、インスタンス変数 @genre に割り当てられている" do
        expect(assigns(:genre)).to be_a_new(Genre)
      end
      
      it "新しいカテゴリーが、インスタンス変数 @category に割り当てられている" do
        expect(assigns(:category)).to be_a_new(Category)
      end
    end
    
    context '@categoriesの絞り込み' do
      let(:genre) { create(:genre) }
      let(:genre2) { create(:genre) }
      let(:category) { create(:category, genre_id: genre.id)}
      let(:category2) { create(:category, genre_id: genre2.id)}
      
      it 'params[:genre_id]が存在する時、変数@categoriesにはそのgenre_idに合致するカテゴリーのみ存在する' do
        get :index, params: { genre_id: genre.id }
        expect(assigns(:categories)).to eq([category])
      end
      
      it 'params[:genre_id]が存在しない時、変数@categoriesには全てのカテゴリーが存在する' do
        get :index
        expect(assigns(:categories)).to eq([category,category2])
      end
    end
    
  end
  
  describe "POST #create" do
    context '正常系' do
      let(:params_data) { build(:genre) }
      it '投稿したジャンルが保存でき、ジャンル、カテゴリー一覧に移動する' do
        expect{post :create, params:{ genre: params_data.attributes }}.to change(Genre, :count).by(1)
        expect_redirect_to_with_notice(admin_genres_path, 'ジャンルを作成しました')
      end
    end
    
    context '異常系' do
      let(:params_data) { build(:genre, name: nil) }
      it 'ジャンルが保存できず、ジャンル、カテゴリー一覧に移動し、エラーメッセージが表示される' do
        expect{post :create, params:{ genre: params_data.attributes }}.to_not change(Genre, :count)
        expect_redirect_to_with_alert(admin_genres_path, 'ジャンルの作成に失敗しました')
      end
    end
  end
  
  describe "GET #edit" do
    let(:genre) { create(:genre) }
    before do
      get :edit, params: {id: genre.id}
    end
    
    context '正常系' do
      it 'ジャンル編集のビューが正しく表示されている' do
        expect(response).to render_template :edit
      end
      
      it "ジャンルが、インスタンス変数 @genre に割り当てられている" do
        expect(assigns(:genre)).to eq(genre)
      end
    end
  end
end