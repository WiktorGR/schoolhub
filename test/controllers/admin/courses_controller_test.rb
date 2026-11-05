require "test_helper"

module Admin
  class CoursesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @course = courses(:english)
    end

    test "guests must sign in" do
      get admin_courses_path

      assert_redirected_to new_session_path
    end

    test "participants and instructors are denied" do
      [ users(:one), users(:instructor) ].each do |user|
        sign_in_as user

        get admin_courses_path
        assert_redirected_to root_path

        post admin_courses_path, params: { course: { name: "Hacked" } }
        assert_redirected_to root_path
      end

      assert_not Course.exists?(name: "Hacked")
    end

    test "admin sees courses" do
      sign_in_as users(:admin)

      get admin_courses_path

      assert_response :success
      assert_select "a", @course.name
    end

    test "admin creates a course" do
      sign_in_as users(:admin)

      assert_difference("Course.count", 1) do
        post admin_courses_path, params: { course: { name: "Niemiecki A2", description: "Opis" } }
      end

      assert_redirected_to admin_course_path(Course.find_by!(name: "Niemiecki A2"))
    end

    test "admin sees errors for an invalid course" do
      sign_in_as users(:admin)

      assert_no_difference("Course.count") do
        post admin_courses_path, params: { course: { name: "" } }
      end

      assert_response :unprocessable_entity
      assert_select "#error_explanation", /Nazwa/
    end

    test "admin updates a course" do
      sign_in_as users(:admin)

      patch admin_course_path(@course), params: { course: { name: "Angielski B2" } }

      assert_redirected_to admin_course_path(@course)
      assert_equal "Angielski B2", @course.reload.name
    end

    test "admin cannot delete a course with groups" do
      sign_in_as users(:admin)

      assert_no_difference("Course.count") do
        delete admin_course_path(@course)
      end

      assert_redirected_to admin_course_path(@course)
    end

    test "admin deletes a course without groups" do
      sign_in_as users(:admin)

      assert_difference("Course.count", -1) do
        delete admin_course_path(courses(:empty))
      end

      assert_redirected_to admin_courses_path
    end

    test "lists are paginated" do
      sign_in_as users(:admin)
      Course.insert_all(Array.new(25) { |i| { name: "Kurs #{format('%02d', i)}", created_at: Time.current, updated_at: Time.current } })

      get admin_courses_path(page: 2)

      assert_response :success
      assert_select "nav[aria-label=Stronicowanie]", /Strona 2 z 2/
    end
  end
end
