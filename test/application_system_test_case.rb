require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1280, 900 ]

  private
    # System tests drive a real browser, so they sign in through the login form.
    def sign_in_via_form(user, password: "password")
      visit new_session_path
      fill_in "Adres e-mail", with: user.email_address
      fill_in "Hasło", with: password
      click_button "Zaloguj się"
      assert_text "Cześć, #{user.name}!"
    end
end
