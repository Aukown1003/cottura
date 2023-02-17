require 'rails_helper'

describe Genre, type: :model do
  describe 'ジャンル保存時' do
    let(:genre) { create(:genre) }
    
    it "ジャンル名があれば保存できる" do
      expect(genre).to be_valid
    end
    
    it "ジャンル名が空欄だと保存できない" do
      genre.name = nil
      genre.valid?
      expect(genre.errors[:name]).to include("が入力されていません。")
    end
  end
  
  describe 'アソシエーション' do
    it 'ジャンルとカテゴリーは、1対Nである' do
      expect(Genre.reflect_on_association(:categories).macro).to eq :has_many
    end
  end
  
end