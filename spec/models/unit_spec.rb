require 'rails_helper'

describe Unit, type: :model do
  describe '材料の単位保存時' do
    let(:unit) { create(:unit) }
    
    it "材料の単位名があれば保存できる" do
      expect(unit).to be_valid
    end
    
    it "材料の単位名が空欄だと保存できない" do
      unit.name = nil
      unit.valid?
      expect(unit.errors[:name]).to include("が入力されていません。")
    end
  end
  
  describe 'アソシエーション' do
    it '材料の単位とレシピの材料は、1対Nである' do
      expect(Unit.reflect_on_association(:recipe_ingredients).macro).to eq :has_many
    end
  end
  
end