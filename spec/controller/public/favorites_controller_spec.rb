require 'rails_helper'

describe Public::FavoritesController, type: :controller do
  before do
    @user = create(:user)
    @recipe_user = create(:user)
    @genre = create(:genre)
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
    save_recipe_with_ingredient_and_step(recipe, unit)
  end
  let(:category) { create(:category, genre_id: @genre.id) }
  let(:unit) { create(:unit) }
  let!(:recipe) { build(:recipe, user_id: @recipe_user.id, category_id: category.id) }
  
  describe 'POST #create' do
    let!(:favorite_params) { build(:favorite, user_id: @user.id, recipe_id: recipe.id) }
    context '正常系' do
      it 'お気に入りが保存される' do
        expect{post :create, xhr: true, params:{ favorite: favorite_params.attributes, recipe_id: recipe.id} }.to change(Favorite, :count).by(1)
      end
    end
  end
  
  describe 'Delete #destroy' do
    let!(:favorite) { create(:favorite, user_id: @user.id, recipe_id: recipe.id) }
    context '正常系' do
      it 'お気に入りが解除される' do
        expect{delete :destroy, xhr: true, params:{ id: favorite.id, recipe_id: recipe.id} }.to change(Favorite, :count).by(-1)
      end
    end
  end
  
end