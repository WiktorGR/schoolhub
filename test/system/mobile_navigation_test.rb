require "application_system_test_case"

class MobileNavigationTest < ApplicationSystemTestCase
  # All system tests share one browser window, so restore the desktop size for the next test.
  teardown do
    page.current_window.resize_to(1280, 900)
  end

  test "menu button reveals navigation links on a phone-sized screen" do
    sign_in_via_form users(:one)
    page.current_window.resize_to(390, 844)

    assert_no_link "Moje zapisy"
    click_on "Menu"
    click_on "Moje zapisy"

    assert_selector "h1", text: "Moje zapisy"
  end
end
