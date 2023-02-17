require 'rails_helper'

describe Category, type: :model do
  describe 'カテゴリー保存時' do
    let(:genre) { create(:genre) }
    let(:category) { build(:category, genre_id: genre.id) }
    
    it "カテゴリー名、ジャンルidがあれば保存できる" do
      expect(category).to be_valid
    end
    
    it "カテゴリー名が空欄だと保存できない" do
      category.name = nil
      category.valid?
      expect(category.errors[:name]).to include("が入力されていません。")
    end
    
    it "ジャンルが未選択だと保存できない" do
      category.genre = nil
      category.valid?
      expect(category.errors[:genre]).to include("が選択されていません。")
    end
    
  end
  describe 'アソシエーション' do
    it 'カテゴリーとジャンルは、N対1である' do
      expect(Category.reflect_on_association(:genre).macro).to eq :belongs_to
    end
    
    it 'カテゴリーとレシピは、1対Nである' do
      expect(Category.reflect_on_association(:recipes).macro).to eq :has_many
    end
  end
end