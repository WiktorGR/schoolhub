require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  setup do
    @group = course_groups(:english_evening) # capacity 2, one seat taken
  end

  test "enrolling into a group with free seats gives an active seat" do
    enrollment = @group.enroll(users(:two))

    assert enrollment.persisted?
    assert enrollment.active?
  end

  test "enrolling into a full group puts the participant on the waitlist" do
    @group.enroll(users(:two))

    enrollment = @group.enroll(users(:three))

    assert enrollment.waitlisted?
    assert_equal 1, enrollment.waitlist_position
    assert_equal 2, @group.seats_taken
  end

  test "waitlist keeps the order of enrolling" do
    @group.enroll(users(:two))
    first = @group.enroll(users(:three))
    second = @group.enroll(users(:four))

    assert_equal 1, first.waitlist_position
    assert_equal 2, second.waitlist_position
  end

  test "a participant cannot hold two open enrollments in one group" do
    enrollment = @group.enroll(users(:one))

    assert_not enrollment.persisted?
    assert enrollment.errors.of_kind?(:base, :already_enrolled)
  end

  test "a waitlisted participant cannot enroll again either" do
    @group.enroll(users(:two))
    @group.enroll(users(:three))

    assert_not @group.enroll(users(:three)).persisted?
  end

  test "database rejects a second open enrollment" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      Enrollment.insert!({ user_id: users(:one).id, course_group_id: @group.id, status: 1,
                          created_at: Time.current, updated_at: Time.current })
    end
  end

  test "a participant can enroll again after cancelling" do
    enrollment = @group.enroll(users(:two))

    assert enrollment.persisted?, "the cancelled fixture enrollment must not block a new one"
  end

  test "only participants can enroll" do
    enrollment = @group.enroll(users(:instructor))

    assert_not enrollment.persisted?
    assert enrollment.errors.of_kind?(:user, :not_a_participant)
  end

  test "cancelling an active seat promotes the first waitlisted participant" do
    @group.enroll(users(:two))
    first_in_line = @group.enroll(users(:three))
    second_in_line = @group.enroll(users(:four))

    promoted = enrollments(:one_in_english_evening).cancel!

    assert_equal [ first_in_line ], promoted
    assert first_in_line.reload.active?
    assert second_in_line.reload.waitlisted?
    assert_equal 1, second_in_line.waitlist_position
  end

  test "cancelling a waitlisted enrollment promotes nobody" do
    @group.enroll(users(:two))
    waitlisted = @group.enroll(users(:three))

    assert_equal [], waitlisted.cancel!
    assert_equal 2, @group.seats_taken
  end

  test "cancelling twice is harmless" do
    enrollment = enrollments(:one_in_english_evening)

    enrollment.cancel!

    assert_equal [], enrollment.cancel!
    assert enrollment.reload.cancelled?
  end

  test "capacity cannot drop below the number of taken seats" do
    @group.enroll(users(:two))

    @group.capacity = 1

    assert_not @group.valid?
    assert @group.errors.of_kind?(:capacity, :below_active_enrollments)
  end

  test "raising capacity can fill seats from the waitlist" do
    @group.enroll(users(:two))
    waitlisted = @group.enroll(users(:three))

    @group.update!(capacity: 3)
    promoted = @group.fill_free_seats_from_waitlist

    assert_equal [ waitlisted ], promoted
    assert waitlisted.reload.active?
  end
end
