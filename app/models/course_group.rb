class CourseGroup < ApplicationRecord
  belongs_to :course
  belongs_to :instructor, class_name: "User", inverse_of: :taught_course_groups
  has_many :enrollments, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :course_id }, length: { maximum: 100 }
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }
  validate :instructor_must_be_an_instructor
  validate :capacity_must_fit_active_enrollments, on: :update

  # Enrolls a participant: a seat if one is free, otherwise the waitlist.
  # The row lock on the group makes concurrent enrollments wait for each other,
  # so two people can never take the last seat at the same time.
  # Returns the enrollment; check `persisted?` and `errors` for the result.
  def enroll(user)
    with_lock do
      enrollments.create(user: user, status: seat_available? ? :active : :waitlisted)
    end
  end

  def seats_taken
    enrollments.active.count
  end

  def seat_available?
    seats_taken < capacity
  end

  # Moves waitlisted participants into free seats, oldest first.
  # Must run inside `with_lock`; returns the promoted enrollments.
  def fill_free_seats_from_waitlist
    free_seats = capacity - seats_taken
    return [] if free_seats <= 0

    enrollments.waitlisted.in_waitlist_order.limit(free_seats).to_a.each do |enrollment|
      enrollment.update!(status: :active)
    end
  end

  private
    def instructor_must_be_an_instructor
      errors.add(:instructor, :not_an_instructor) if instructor && !instructor.instructor?
    end

    def capacity_must_fit_active_enrollments
      if capacity_changed? && capacity.to_i.positive? && capacity < seats_taken
        errors.add(:capacity, :below_active_enrollments, count: seats_taken)
      end
    end
end
