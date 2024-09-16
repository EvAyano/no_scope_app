require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get my_page" do
    get users_my_page_url
    assert_response :success
  end
end
