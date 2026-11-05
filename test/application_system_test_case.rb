require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # dom_id lets tests target the same element ids the views render.
  include ActionView::RecordIdentifier

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1280, 900 ] do |options|
    # Fixture users sign in with a weak password. Chrome's password manager then opens a
    # native "password found in a data breach" bubble that silently swallows later clicks.
    options.add_preference("credentials_enable_service", false)
    options.add_preference("profile.password_manager_enabled", false)
    options.add_preference("profile.password_manager_leak_detection", false)
    options.add_argument("--disable-features=PasswordLeakDetection")
  end

  private
    # System tests drive a real browser, so they sign in through the login form.
    def sign_in_via_form(user, password: "password")
      visit new_session_path
      fill_in "Adres e-mail", with: user.email_address
      fill_in "Hasło", with: password
      click_button "Zaloguj się"
      assert_text "Cześć, #{user.name}!"
    end

    # Waits until the sign out has finished; otherwise the next visit can race the request.
    def sign_out_via_menu
      click_on "Wyloguj"
      assert_no_button "Wyloguj"
    end
end
