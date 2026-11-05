require "application_system_test_case"

class AdminManagesCoursesTest < ApplicationSystemTestCase
  test "admin creates a course with a group and a participant sees it" do
    sign_in_via_form users(:admin)

    click_on "Zarządzaj kursami"
    click_on "Dodaj kurs"
    fill_in "Nazwa", with: "Francuski A1"
    click_on "Zapisz"
    assert_text "Kurs został dodany."

    click_on "Dodaj grupę"
    fill_in "Nazwa grupy", with: "Piątki 17:00"
    fill_in "Limit miejsc", with: "6"
    select users(:instructor).name, from: "Instruktor"
    click_on "Zapisz"
    assert_text "Grupa została dodana."

    sign_out_via_menu
    sign_in_via_form users(:one)
    click_on "Kursy", match: :first
    click_on "Francuski A1"

    assert_text "Piątki 17:00"
    assert_text users(:instructor).name
  end
end
