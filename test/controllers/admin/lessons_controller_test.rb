require "test_helper"

module Admin
  class LessonsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @group = course_groups(:english_evening)
    end

    test "non-admins are denied" do
      sign_in_as users(:instructor)

      assert_no_difference("Lesson.count") do
        post admin_course_group_lessons_path(@group), params: { lesson: lesson_params }
      end
      assert_redirected_to root_path
    end

    test "admin adds a weekly series" do
      sign_in_as users(:admin)

      assert_difference("@group.lessons.count", 4) do
        post admin_course_group_lessons_path(@group), params: { lesson: lesson_params, weeks: 4 }
      end

      assert_redirected_to admin_course_group_path(@group)
    end

    test "admin sees errors for invalid times" do
      sign_in_as users(:admin)

      post admin_course_group_lessons_path(@group), params: { lesson: lesson_params(ends_at: "2027-01-12T17:00") }

      assert_response :unprocessable_entity
      assert_select "#error_explanation", /Koniec/
    end

    test "admin updates a lesson" do
      sign_in_as users(:admin)

      patch admin_lesson_path(lessons(:english_next)), params: { lesson: { topic: "Nowy temat" } }

      assert_redirected_to admin_course_group_path(@group)
      assert_equal "Nowy temat", lessons(:english_next).reload.topic
    end

    test "admin deletes a lesson" do
      sign_in_as users(:admin)

      assert_difference("Lesson.count", -1) do
        delete admin_lesson_path(lessons(:english_next))
      end
    end

    private
      def lesson_params(overrides = {})
        { starts_at: "2027-01-12T18:00", ends_at: "2027-01-12T19:30", topic: "Słownictwo" }.merge(overrides)
      end
  end
end
