require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  test "guests must sign in" do
    get courses_path

    assert_redirected_to new_session_path
  end

  test "participant sees the list of courses" do
    sign_in_as users(:one)

    get courses_path

    assert_response :success
    assert_select "h2", courses(:english).name
  end

  test "participant sees course groups with instructors" do
    sign_in_as users(:one)

    get course_path(courses(:english))

    assert_response :success
    assert_select "##{ActionView::RecordIdentifier.dom_id(course_groups(:english_evening))}", /Ewa Kowalska/
  end
end
