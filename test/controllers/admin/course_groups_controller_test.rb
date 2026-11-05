require "test_helper"

module Admin
  class CourseGroupsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @course = courses(:english)
      @group = course_groups(:english_evening)
    end

    test "non-admins are denied" do
      sign_in_as users(:instructor)

      get admin_course_group_path(@group)
      assert_redirected_to root_path

      patch admin_course_group_path(@group), params: { course_group: { capacity: 99 } }
      assert_redirected_to root_path
      assert_equal 2, @group.reload.capacity
    end

    test "admin creates a group" do
      sign_in_as users(:admin)

      assert_difference("@course.course_groups.count", 1) do
        post admin_course_course_groups_path(@course),
             params: { course_group: { name: "Środy 17:00", capacity: 8, instructor_id: users(:instructor).id } }
      end

      assert_redirected_to admin_course_group_path(CourseGroup.find_by!(name: "Środy 17:00"))
    end

    test "admin cannot assign a participant as instructor" do
      sign_in_as users(:admin)

      assert_no_difference("CourseGroup.count") do
        post admin_course_course_groups_path(@course),
             params: { course_group: { name: "Środy 17:00", capacity: 8, instructor_id: users(:one).id } }
      end

      assert_response :unprocessable_entity
      assert_select "#error_explanation", /instruktora/
    end

    test "admin updates a group" do
      sign_in_as users(:admin)

      patch admin_course_group_path(@group), params: { course_group: { capacity: 15 } }

      assert_redirected_to admin_course_group_path(@group)
      assert_equal 15, @group.reload.capacity
    end

    test "admin deletes a group" do
      sign_in_as users(:admin)

      assert_difference("CourseGroup.count", -1) do
        delete admin_course_group_path(course_groups(:english_morning))
      end

      assert_redirected_to admin_course_path(@course)
    end
  end
end
