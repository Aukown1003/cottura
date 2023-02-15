require 'rails_helper'

describe User, type: :model do
  describe '新規登録時' do
    it "名前、email、紹介、パスワードがあれば登録できる" do
      user = build(:user)
      expect(user).to be_valid
    end
  
    it "名前が空欄だと登録できない" do
      user = build(:user, name: nil)
      user.valid?
      expect(user.errors[:name]).to include("が入力されていません。")
    end
    
    it "emailが空欄だと登録できない" do
      user = build(:user, email: nil)
      user.valid?
      expect(user.errors[:email]).to include("が入力されていません。")
    end
    
    it "紹介文が空欄だと登録できない" do
      user = build(:user, content: nil)
      user.valid?
      expect(user.errors[:content]).to include("が入力されていません。")
    end
    
    it "パスワードが空欄だと登録できない" do
      user = build(:user, password: nil)
      user.valid?
      expect(user.errors[:password]).to include("が入力されていません。")
    end
    
    it "パスワードが5文字以下だと登録できない" do
      password = Faker::Internet.password(min_length: 5, max_length: 5)
      user = build(:user, password: password, password_confirmation: password)
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
end