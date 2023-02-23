require 'rails_helper'

RSpec.describe Public::RecipesHelper, type: :helper do
  describe "RecipesHelper" do
    before do
      @user = create(:user)
      @gest_user = create(:user, email: 'guest@example.com')
      @recipe_user = create(:user)
      @genre = create(:genre)
    end
    
    let(:category) { create(:category, genre_id: @genre.id) }
    let(:unit) { create(:unit) }
    let!(:recipe) { build(:recipe, user_id: @recipe_user.id, category_id: category.id) }
    
    context "review_average" do
      before { save_recipe_with_ingredient_and_step(recipe, unit) }
      let!(:review) { create(:review, recipe_id: recipe.id, user_id: @user.id, score: 1) }
      let!(:review2) { create(:review, recipe_id: recipe.id, user_id: @user.id, score: 2) }
      it 'レビューが2件有り、点数が1と2である場合、平均は1.5になる ' do
        expect(helper.review_average(recipe.reviews)).to eq(1.5)
      end
    end
    
    context "view_time_data" do
      it 'レシピの調理時間(total_time) = 150の場合、2時間30分と表示される' do
        expect(helper.view_time_data(150)).to eq("2時間30分")
      end
      
      it 'レシピ一覧の、「絞り込み用の時間」の値が150の場合、2時間30分以内とリストに表示される' do
        expect(helper.view_time_data(150, suffix = "以内")).to eq("2時間30分以内")
      end
    end
      
    context 'material_quantity_after_conversion' do
      it 'sessionの値との積を小数点第2位で四捨五入し、小数点以下の0を省略する' do
        session[:recalculation] = 4.3
        expect(helper.material_quantity_after_conversion(3)).to eq("12.9")
        expect(helper.material_quantity_after_conversion(3.1)).to eq("13.3")
        expect(helper.material_quantity_after_conversion(3.5)).to eq("15.1")
      end
    end
      
    context 'material_quantity' do
      it '入力された値を小数点第2位で四捨五入し、小数点以下の0を省略する' do
        expect(helper.material_quantity(1.5)).to eq("1.5")
        expect(helper.material_quantity(1.50)).to eq("1.5")
        expect(helper.material_quantity(1.54)).to eq("1.5")
        expect(helper.material_quantity(1.55)).to eq("1.6")
      end
    end
    
    context 'ingredient_quantity' do
      before do
        recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, quantity: 1.3, unit_id: unit.id))
        recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, quantity: 1.50, unit_id: unit.id))
        recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, quantity: 1.52, unit_id: unit.id))
        recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, quantity: 1.58, unit_id: unit.id))
        recipe.recipe_steps.build(attributes_for(:recipe_step))
        recipe.save
        @ingredient = recipe.recipe_ingredients
      end
      
      it 'sessionが有る場合、sessionの値との積を小数点第2位で四捨五入し、小数点以下の0を省略する' do
        session[:recalculation] = 2.0
        expect(helper.ingredient_quantity(@ingredient.first)).to eq("2.6")
        expect(helper.ingredient_quantity(@ingredient.second)).to eq("3")
        expect(helper.ingredient_quantity(@ingredient.third)).to eq("3")
        expect(helper.ingredient_quantity(@ingredient.fourth)).to eq("3.2")
      end
      
      it 'sessionが無い場合、入力された値を小数点第2位で四捨五入し、小数点以下の0を省略する' do
        expect(helper.ingredient_quantity(@ingredient.first)).to eq("1.3")
        expect(helper.ingredient_quantity(@ingredient.second)).to eq("1.5")
        expect(helper.ingredient_quantity(@ingredient.third)).to eq("1.5")
        expect(helper.ingredient_quantity(@ingredient.fourth)).to eq("1.6")
      end
    end
    
    context 'convert_rational' do
      it '入力された値を分数に変換する。ただし、1を超えるものは整数へと変換する' do
        expect(helper.convert_rational(0.3)).to eq("3/10")
        expect(helper.convert_rational(0.5)).to eq("1/2")
        expect(helper.convert_rational(0.8)).to eq("4/5")
        expect(helper.convert_rational(1.1)).to eq("1と1/10")
        expect(helper.convert_rational(1.6)).to eq("1と3/5")
      end
    end
    
  end
end
