require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    test "non-admins are denied" do
      sign_in_as users(:one)

      patch admin_user_path(users(:one)), params: { user: { role: "admin" } }

      assert_redirected_to root_path
      assert users(:one).reload.participant?
    end

    test "admin lists users filtered by role" do
      sign_in_as users(:admin)

      get admin_users_path(role: "instructor")

      assert_response :success
      assert_select "p", users(:instructor).name
      assert_select "p", text: users(:one).name, count: 0
    end

    test "admin changes a user's role" do
      sign_in_as users(:admin)

      patch admin_user_path(users(:one)), params: { user: { role: "instructor" } }

      assert_redirected_to admin_users_path
      assert users(:one).reload.instructor?
    end

    test "admin only changes the role" do
      sign_in_as users(:admin)

      patch admin_user_path(users(:one)), params: { user: { role: "instructor", email_address: "changed@example.com" } }

      assert_equal "one@example.com", users(:one).reload.email_address
    end

    test "admin cannot change their own role" do
      sign_in_as users(:admin)

      patch admin_user_path(users(:admin)), params: { user: { role: "participant" } }

      assert_redirected_to admin_users_path
      assert users(:admin).reload.admin?
    end
  end
end
