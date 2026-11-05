require "test_helper"

class LessonTest < ActiveSupport::TestCase
  setup do
    @group = course_groups(:english_evening)
  end

  test "must end after it starts" do
    lesson = @group.lessons.new(starts_at: 1.day.from_now, ends_at: 1.day.from_now - 1.hour)

    assert_not lesson.valid?
    assert lesson.errors.of_kind?(:ends_at, :before_start)
  end

  test "database rejects an end before the start" do
    assert_raises(ActiveRecord::StatementInvalid) do
      lessons(:english_next).update_columns(ends_at: lessons(:english_next).starts_at - 1.minute)
    end
  end

  test "upcoming skips finished lessons" do
    assert_includes Lesson.upcoming, lessons(:english_next)
    assert_not_includes Lesson.upcoming, lessons(:english_past)
  end

  test "participants see only lessons of groups where they hold a seat" do
    lessons = Lesson.for_participant(users(:one))

    assert_includes lessons, lessons(:english_next)
    assert_not_includes lessons, lessons(:salsa_next)
  end

  test "waitlisted and cancelled enrollments do not add lessons to the plan" do
    assert_empty Lesson.for_participant(users(:two)) # only a cancelled enrollment
  end

  test "instructors see only lessons of their own groups" do
    lessons = Lesson.for_instructor(users(:instructor))

    assert_includes lessons, lessons(:salsa_next)
    assert_not_includes lessons, lessons(:english_morning_next)
  end

  test "weekly series creates one lesson per week at the same local time" do
    starts_at = Time.zone.local(2027, 3, 16, 18, 0) # series crosses the switch to summer time

    assert_difference("Lesson.count", 3) do
      lesson = Lesson.create_weekly_series({ course_group: @group, starts_at: starts_at, ends_at: starts_at + 90.minutes }, weeks: 3)
      assert lesson.errors.none?
    end

    created = @group.lessons.where(starts_at: starts_at..).order(:starts_at)
    assert_equal [ 18, 18, 18 ], created.map { |lesson| lesson.starts_at.hour }
    assert_equal [ 16, 23, 30 ], created.map { |lesson| lesson.starts_at.day }
  end

  test "weekly series saves nothing when the data is invalid" do
    starts_at = 1.week.from_now

    assert_no_difference("Lesson.count") do
      lesson = Lesson.create_weekly_series({ course_group: @group, starts_at: starts_at, ends_at: starts_at - 1.hour }, weeks: 4)
      assert lesson.errors.of_kind?(:ends_at, :before_start)
    end
  end

  test "weekly series is capped" do
    starts_at = 1.week.from_now

    assert_difference("Lesson.count", Lesson::MAX_WEEKS_IN_SERIES) do
      Lesson.create_weekly_series({ course_group: @group, starts_at: starts_at, ends_at: starts_at + 1.hour }, weeks: 500)
    end
  end
end
