require "test_helper"

class CourseTest < ActiveSupport::TestCase
  test "requires a name" do
    course = Course.new(name: "")

    assert_not course.valid?
    assert course.errors.of_kind?(:name, :blank)
  end

  test "requires a unique name" do
    course = Course.new(name: courses(:english).name)

    assert_not course.valid?
    assert course.errors.of_kind?(:name, :taken)
  end

  test "cannot be destroyed while it has groups" do
    course = courses(:english)

    assert_not course.destroy
    assert Course.exists?(course.id)
  end

  test "can be destroyed without groups" do
    assert courses(:empty).destroy
  end
end
