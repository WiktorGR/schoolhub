require "application_system_test_case"

class InstructorChecksAttendanceTest < ApplicationSystemTestCase
  test "instructor marks a participant present and an entry is used once" do
    lesson = lessons(:english_past)

    sign_in_via_form users(:instructor)
    click_on "Mój plan", match: :first
    within("##{dom_id(lesson)}") { click_on "Obecność" }

    check users(:one).name
    click_on "Zapisz obecność"
    assert_text "Obecność została zapisana."

    click_on "Zapisz obecność"
    assert_text "Obecność została zapisana."

    sign_out_via_menu
    sign_in_via_form users(:one)
    click_on "Mój karnet"
    assert_text "Pozostało wejść: 8"
  end
end
