require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = course_groups(:english_evening)
  end

  test "guests must sign in" do
    post course_group_enrollments_path(@group)

    assert_redirected_to new_session_path
  end

  test "instructors and admins cannot enroll" do
    [ users(:instructor), users(:admin) ].each do |user|
      sign_in_as user

      assert_no_difference("Enrollment.count") do
        post course_group_enrollments_path(@group)
      end
      assert_redirected_to root_path
    end
  end

  test "participant takes a free seat" do
    sign_in_as users(:two)

    assert_difference("Enrollment.active.count", 1) do
      post course_group_enrollments_path(@group)
    end

    assert_redirected_to course_path(@group.course)
    assert_equal "Masz miejsce w grupie Wtorki 18:00.", flash[:notice]
  end

  test "participant lands on the waitlist of a full group" do
    @group.enroll(users(:three))
    sign_in_as users(:two)

    post course_group_enrollments_path(@group)

    assert_match "liście rezerwowej (pozycja 1)", flash[:notice]
  end

  test "enrolling twice shows an error" do
    sign_in_as users(:one)

    assert_no_difference("Enrollment.count") do
      post course_group_enrollments_path(@group)
    end

    assert_match "Masz już miejsce", flash[:alert]
  end

  test "participant cancels their enrollment" do
    sign_in_as users(:one)

    delete enrollment_path(enrollments(:one_in_english_evening))

    assert enrollments(:one_in_english_evening).reload.cancelled?
  end

  test "participant cannot cancel someone else's enrollment" do
    sign_in_as users(:two)

    delete enrollment_path(enrollments(:one_in_english_evening))

    assert_response :not_found
    assert enrollments(:one_in_english_evening).reload.active?
  end

  test "participant sees their enrollments" do
    sign_in_as users(:one)

    get enrollments_path

    assert_response :success
    assert_select "a", courses(:english).name
  end

  test "course page shows free seats and the participant's status" do
    sign_in_as users(:one)

    get course_path(courses(:english))

    assert_select "##{ActionView::RecordIdentifier.dom_id(@group)}" do
      assert_select "strong", "1"
      assert_select ".badge", "Masz miejsce"
    end
  end
end
