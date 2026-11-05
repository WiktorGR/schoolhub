require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to the sign in page" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "shows the home page to signed in users" do
    sign_in_as users(:one)

    get root_path

    assert_response :success
    assert_select "h1", "Cześć, Anna Nowak!"
  end
end
