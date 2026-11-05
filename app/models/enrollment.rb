class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course_group

  enum :status, { active: 0, waitlisted: 1, cancelled: 2 }, validate: true

  scope :not_cancelled, -> { where.not(status: :cancelled) }
  # First come, first served; id breaks ties between identical timestamps.
  scope :in_waitlist_order, -> { order(:created_at, :id) }

  validate :user_must_be_a_participant, on: :create
  validate :only_one_open_enrollment_per_group, on: :create

  # Cancels the enrollment and, if it freed a seat, gives it to the next person
  # on the waitlist. Returns the enrollments that were promoted (possibly empty),
  # so the caller can notify those participants.
  def cancel!
    course_group.with_lock do
      # Re-read under the lock: a parallel request may have cancelled it already.
      reload
      if cancelled?
        []
      else
        update!(status: :cancelled, cancelled_at: Time.current)
        course_group.fill_free_seats_from_waitlist
      end
    end
  end

  def waitlist_position
    return unless waitlisted?

    course_group.enrollments.waitlisted.in_waitlist_order.pluck(:id).index(id) + 1
  end

  private
    def user_must_be_a_participant
      errors.add(:user, :not_a_participant) if user && !user.participant?
    end

    def only_one_open_enrollment_per_group
      if course_group && course_group.enrollments.not_cancelled.exists?(user_id: user_id)
        errors.add(:base, :already_enrolled)
      end
    end
end
