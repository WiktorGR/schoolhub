require "test_helper"

class SchedulesControllerTest < ActionDispatch::IntegrationTest
  test "guests must sign in" do
    get schedule_path

    assert_redirected_to new_session_path
  end

  test "participant sees upcoming lessons of their groups" do
    sign_in_as users(:one)

    get schedule_path

    assert_response :success
    assert_select "#lesson_#{lessons(:english_next).id}", /Present Perfect/
    assert_select "#lesson_#{lessons(:english_past).id}", count: 0
    assert_select "#lesson_#{lessons(:salsa_next).id}", count: 0
  end

  test "participant without enrollments sees an empty state" do
    sign_in_as users(:two)

    get schedule_path

    assert_select "p", /Brak nadchodzących zajęć/
  end

  test "instructor sees lessons of their groups" do
    sign_in_as users(:instructor)

    get schedule_path

    assert_select "#lesson_#{lessons(:salsa_next).id}"
    assert_select "#lesson_#{lessons(:english_morning_next).id}", count: 0
  end
end
