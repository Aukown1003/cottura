require 'rails_helper'

describe Admin::UsersController, type: :controller do
  before do
    @admin = create(:admin)
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @admin
  end
  
  it '' do
  end
end
