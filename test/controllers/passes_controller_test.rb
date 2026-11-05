require "test_helper"

class PassesControllerTest < ActionDispatch::IntegrationTest
  test "participant sees their remaining entries" do
    sign_in_as users(:one)

    get passes_path

    assert_response :success
    assert_select "strong", "9"
  end

  test "participant without a pass sees an empty state" do
    sign_in_as users(:two)

    get passes_path

    assert_select "p", /Nie masz jeszcze karnetu/
  end

  test "staff do not have a pass page" do
    sign_in_as users(:instructor)

    get passes_path

    assert_redirected_to root_path
  end
end
