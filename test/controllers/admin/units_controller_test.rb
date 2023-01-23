require "test_helper"

class Admin::UnitsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_units_index_url
    assert_response :success
  end

  test "should get edit" do
    get admin_units_edit_url
    assert_response :success
  end
end
