require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lesson = lessons(:english_past) # group english_evening, instructor: users(:instructor)
  end

  test "guests must sign in" do
    get edit_lesson_attendance_path(@lesson)

    assert_redirected_to new_session_path
  end

  test "participants are denied" do
    sign_in_as users(:one)

    patch lesson_attendance_path(@lesson), params: { present_user_ids: [ users(:one).id ] }

    assert_redirected_to root_path
    assert_empty @lesson.attendances
  end

  test "an instructor of another group gets not found" do
    sign_in_as users(:other_instructor)

    patch lesson_attendance_path(@lesson), params: { present_user_ids: [ users(:one).id ] }

    assert_response :not_found
    assert_empty @lesson.attendances
  end

  test "the group's instructor sees the attendance sheet" do
    sign_in_as users(:instructor)

    get edit_lesson_attendance_path(@lesson)

    assert_response :success
    assert_select "label", /Anna Nowak/
  end

  test "the group's instructor records attendance" do
    sign_in_as users(:instructor)

    patch lesson_attendance_path(@lesson), params: { present_user_ids: [ users(:one).id ] }

    assert_redirected_to edit_lesson_attendance_path(@lesson)
    assert_equal "Obecność została zapisana.", flash[:notice]
    assert @lesson.attendances.find_by!(user: users(:one)).present?
  end

  test "admin records attendance for any group" do
    sign_in_as users(:admin)

    patch lesson_attendance_path(@lesson), params: { present_user_ids: [ users(:one).id ] }

    assert @lesson.attendances.find_by!(user: users(:one)).present?
  end

  test "notice warns about participants without entries" do
    course_groups(:english_evening).enroll(users(:three))
    sign_in_as users(:instructor)

    patch lesson_attendance_path(@lesson), params: { present_user_ids: [ users(:three).id ] }

    assert_match "Bez wejść na karnecie: 1.", flash[:notice]
  end

  test "submitting the form twice charges once" do
    sign_in_as users(:instructor)

    2.times { patch lesson_attendance_path(@lesson), params: { present_user_ids: [ users(:one).id ] } }

    assert_equal 8, users(:one).passes.sum(:entries_remaining)
  end
end
