require "test_helper"

class CourseGroupTest < ActiveSupport::TestCase
  test "is valid with fixture data" do
    assert course_groups(:english_evening).valid?
  end

  test "requires a positive capacity" do
    group = course_groups(:english_evening)
    group.capacity = 0

    assert_not group.valid?
    assert group.errors.of_kind?(:capacity, :greater_than)
  end

  test "database rejects a non-positive capacity" do
    assert_raises(ActiveRecord::StatementInvalid) do
      course_groups(:english_evening).update_column(:capacity, 0)
    end
  end

  test "requires a name unique within its course" do
    group = courses(:english).course_groups.new(name: course_groups(:english_evening).name, capacity: 5, instructor: users(:instructor))

    assert_not group.valid?
    assert group.errors.of_kind?(:name, :taken)
  end

  test "allows the same name in another course" do
    group = courses(:salsa).course_groups.new(name: course_groups(:english_evening).name, capacity: 5, instructor: users(:instructor))

    assert group.valid?
  end

  test "requires the instructor to have the instructor role" do
    group = course_groups(:english_evening)
    group.instructor = users(:one)

    assert_not group.valid?
    assert group.errors.of_kind?(:instructor, :not_an_instructor)
  end
end
