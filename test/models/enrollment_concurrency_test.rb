require "test_helper"

# Proves that the row lock in CourseGroup#enroll stops overbooking when several
# requests try to take the last seat at the same moment.
class EnrollmentConcurrencyTest < ActiveSupport::TestCase
  # Each thread uses its own database connection, so the data must be really
  # committed rather than hidden inside a test transaction.
  self.use_transactional_tests = false

  setup do
    @course = Course.create!(name: "Concurrency #{SecureRandom.hex(4)}")
    instructor = User.create!(name: "Lock Instructor", email_address: "lock-#{SecureRandom.hex(4)}@example.com",
                              password: "password", role: :instructor)
    @group = @course.course_groups.create!(name: "Last seat", capacity: 1, instructor: instructor)
    @participants = Array.new(5) do |i|
      User.create!(name: "Racer #{i}", email_address: "racer-#{i}-#{SecureRandom.hex(4)}@example.com", password: "password")
    end
  end

  teardown do
    Enrollment.where(course_group: @group).delete_all
    CourseGroup.where(id: @group.id).delete_all
    Course.where(id: @course.id).delete_all
    User.where(id: @participants.map(&:id) + [ @group.instructor_id ]).delete_all
  end

  test "parallel enrollments never exceed the capacity" do
    threads = @participants.map do |participant|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          CourseGroup.find(@group.id).enroll(participant)
        end
      end
    end
    threads.each(&:join)

    assert_equal 1, @group.enrollments.active.count
    assert_equal 4, @group.enrollments.waitlisted.count
  end
end
