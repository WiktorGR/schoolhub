require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  setup do
    @lesson = lessons(:english_past)
    @participant = users(:one) # holds a seat; passes: one_old (1 left, older), one_new (8 left)
  end

  test "roster lists current seat holders" do
    assert_equal [ @participant ], @lesson.attendance_roster.to_a
  end

  test "marking present takes one entry from the oldest pass with entries left" do
    @lesson.record_attendance([ @participant.id ])

    attendance = @lesson.attendances.find_by!(user: @participant)
    assert attendance.present?
    assert_equal passes(:one_old), attendance.pass
    assert_equal 0, passes(:one_old).reload.entries_remaining
    assert_equal 8, passes(:one_new).reload.entries_remaining
  end

  test "saving the same sheet again does not charge twice" do
    @lesson.record_attendance([ @participant.id ])
    @lesson.record_attendance([ @participant.id ])
    @lesson.record_attendance([ @participant.id.to_s ])

    assert_equal 1, @lesson.attendances.count
    assert_equal 8, @participant.passes.sum(:entries_remaining) # 9 before, exactly one used
  end

  test "marking absent gives the entry back" do
    @lesson.record_attendance([ @participant.id ])

    @lesson.record_attendance([])

    attendance = @lesson.attendances.find_by!(user: @participant)
    assert_not attendance.present?
    assert_nil attendance.pass
    assert_equal 1, passes(:one_old).reload.entries_remaining
  end

  test "unticked participants are recorded as absent without charging" do
    @lesson.record_attendance([])

    attendance = @lesson.attendances.find_by!(user: @participant)
    assert_not attendance.present?
    assert_equal 9, @participant.passes.sum(:entries_remaining)
  end

  test "presence without entries left is recorded but charges nothing" do
    course_groups(:english_evening).enroll(users(:three)) # three has only an empty pass

    @lesson.record_attendance([ users(:three).id ])

    attendance = @lesson.attendances.find_by!(user: users(:three))
    assert attendance.present?
    assert_not attendance.charged?
    assert_equal 0, passes(:three_empty).reload.entries_remaining
  end

  test "a participant without entries is not charged later when the sheet is saved again" do
    course_groups(:english_evening).enroll(users(:three))
    @lesson.record_attendance([ users(:three).id ])
    users(:three).passes.create!(entries_total: 5)

    @lesson.record_attendance([ users(:three).id ])

    assert_equal 5, users(:three).passes.sum(:entries_remaining)
  end

  test "ids from outside the roster are ignored" do
    @lesson.record_attendance([ @participant.id, users(:two).id ])

    assert_not @lesson.attendances.exists?(user: users(:two))
  end

  test "only managers see the lesson" do
    assert_includes Lesson.manageable_by(users(:instructor)), @lesson
    assert_includes Lesson.manageable_by(users(:admin)), @lesson
    assert_not_includes Lesson.manageable_by(users(:other_instructor)), @lesson
    assert_empty Lesson.manageable_by(users(:one))
  end
end
