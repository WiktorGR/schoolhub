require "test_helper"

module Admin
  class CourseGroupsControllerTest < ActionDispatch::IntegrationTest
    include ActionMailer::TestHelper

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

    test "admin deletes an empty group" do
      sign_in_as users(:admin)
      group = @course.course_groups.create!(name: "Do usunięcia", capacity: 5, instructor: users(:instructor))

      assert_difference("CourseGroup.count", -1) do
        delete admin_course_group_path(group)
      end

      assert_redirected_to admin_course_path(@course)
    end

    test "admin cannot delete a group with lessons or enrollments" do
      sign_in_as users(:admin)

      assert_no_difference("CourseGroup.count") do
        delete admin_course_group_path(course_groups(:english_morning))
      end

      assert_redirected_to admin_course_group_path(course_groups(:english_morning))
    end

    test "admin sees enrolled and waitlisted participants" do
      @group.enroll(users(:two))
      @group.enroll(users(:three))
      sign_in_as users(:admin)

      get admin_course_group_path(@group)

      assert_select "section", /Zapisani \(2\/2\).*Anna Nowak/m
      assert_select "section", /Lista rezerwowa \(1\).*Ola Lewandowska/m
    end

    test "raising capacity promotes waitlisted participants" do
      @group.enroll(users(:two))
      waitlisted = @group.enroll(users(:three))
      sign_in_as users(:admin)

      assert_enqueued_email_with EnrollmentMailer, :promoted, args: [ waitlisted ] do
        patch admin_course_group_path(@group), params: { course_group: { capacity: 3 } }
      end

      assert waitlisted.reload.active?
    end

    test "capacity cannot be lowered below taken seats" do
      @group.enroll(users(:two))
      sign_in_as users(:admin)

      patch admin_course_group_path(@group), params: { course_group: { capacity: 1 } }

      assert_response :unprocessable_entity
      assert_equal 2, @group.reload.capacity
    end
  end
end
