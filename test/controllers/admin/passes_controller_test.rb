require "test_helper"

module Admin
  class PassesControllerTest < ActionDispatch::IntegrationTest
    test "non-admins cannot issue passes" do
      sign_in_as users(:one)

      assert_no_difference("Pass.count") do
        post admin_user_passes_path(users(:one)), params: { pass: { entries_total: 100 } }
      end
      assert_redirected_to root_path
    end

    test "admin issues a pass" do
      sign_in_as users(:admin)

      assert_difference("users(:two).passes.count", 1) do
        post admin_user_passes_path(users(:two)), params: { pass: { entries_total: 10 } }
      end

      assert_redirected_to edit_admin_user_path(users(:two))
      assert_equal 10, users(:two).passes.last.entries_remaining
    end

    test "remaining entries cannot be set from the form" do
      sign_in_as users(:admin)

      post admin_user_passes_path(users(:two)), params: { pass: { entries_total: 10, entries_remaining: 999 } }

      assert_equal 10, users(:two).passes.last.entries_remaining
    end

    test "admin sees errors for an invalid pass" do
      sign_in_as users(:admin)

      post admin_user_passes_path(users(:two)), params: { pass: { entries_total: 0 } }

      assert_response :unprocessable_entity
      assert_select "#error_explanation", /Liczba wejść/
    end
  end
end
