require 'rails_helper'

describe User, type: :model do
  let(:user) { create(:user) }
  
  describe '新規登録時' do
    it "名前、email、紹介、パスワードがあれば登録できる" do
      expect(user).to be_valid
    end
  
    it "名前が空欄だと登録できない" do
      user.name = nil
      user.valid?
      expect(user.errors[:name]).to include("が入力されていません。")
    end
    
    it "emailが空欄だと登録できない" do
      user.email = nil
      user.valid?
      expect(user.errors[:email]).to include("が入力されていません。")
    end
    
    it "紹介文が空欄だと登録できない" do
      user.content = nil
      user.valid?
      expect(user.errors[:content]).to include("が入力されていません。")
    end
    
    it "パスワードが空欄だと登録できない" do
      user.password = nil
      user.valid?
      expect(user.errors[:password]).to include("が入力されていません。")
    end
    
    it "パスワードが5文字以下だと登録できない" do
      invalid_password = Faker::Internet.password(min_length: 5, max_length: 5)
      user = build(:user, password: invalid_password, password_confirmation: invalid_password)
      user.valid?
      expect(user.errors[:password]).to include("は6文字以上に設定して下さい。")
    end
    
    it "登録済みのemailでは登録できない" do
      email = Faker::Internet.email
      user = create(:user, email: email)
      user2 = build(:user, email: email)
      user2.valid?
      expect(user2.errors[:email]).to include("は既に使用されています。")
    end
  end
  
  describe 'アソシエーション' do
    it 'ユーザーとレシピは、N対1である' do
      expect(User.reflect_on_association(:recipes).macro).to eq :has_many
    end
    
    it 'ユーザーとレビューは、N対1である' do
      expect(User.reflect_on_association(:reviews).macro).to eq :has_many
    end
    
    it 'ユーザーとお気に入りは、N対1である' do
      expect(User.reflect_on_association(:favorites).macro).to eq :has_many
    end
    
    it 'ユーザーとレポートは、N対1である' do
      expect(User.reflect_on_association(:reports).macro).to eq :has_many
    end
  end
end