require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path

    assert_response :success
  end

  test "create with valid data signs up a participant and signs them in" do
    assert_difference("User.count", 1) do
      post registration_path, params: { user: valid_params }
    end

    user = User.find_by!(email_address: "new@example.com")
    assert user.participant?
    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create ignores a role sent in the form" do
    post registration_path, params: { user: valid_params.merge(role: "admin") }

    assert User.find_by!(email_address: "new@example.com").participant?
  end

  test "create with invalid data shows errors" do
    assert_no_difference("User.count") do
      post registration_path, params: { user: valid_params.merge(email_address: users(:one).email_address) }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Adres e-mail/
    assert_nil cookies[:session_id]
  end

  private
    def valid_params
      { email_address: "new@example.com", password: "secret123", password_confirmation: "secret123" }
    end
end
