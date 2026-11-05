require "application_system_test_case"

class ParticipantEnrollsTest < ApplicationSystemTestCase
  test "participant takes the last seat, the next one waits and moves up after a cancellation" do
    group = course_groups(:english_evening) # one of two seats is free

    sign_in_via_form users(:two)
    visit course_path(group.course)
    within("##{dom_id(group)}") { click_on "Zapisz się" }
    assert_text "Masz miejsce w grupie Wtorki 18:00."

    click_on "Wyloguj"
    sign_in_via_form users(:three)
    visit course_path(group.course)
    within("##{dom_id(group)}") { click_on "Zapisz się na listę rezerwową" }
    assert_text "Jesteś na liście rezerwowej (pozycja 1)"

    click_on "Wyloguj"
    sign_in_via_form users(:two)
    click_on "Moje zapisy"
    accept_confirm { click_on "Zrezygnuj" }
    assert_text "Zrezygnowano z zapisu"

    click_on "Wyloguj"
    sign_in_via_form users(:three)
    click_on "Moje zapisy"
    assert_text "Masz miejsce"
  end
end
