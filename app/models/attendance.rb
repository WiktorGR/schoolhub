class Attendance < ApplicationRecord
  belongs_to :lesson
  belongs_to :user
  belongs_to :pass, optional: true

  validates :user_id, uniqueness: { scope: :lesson_id }

  # Sets presence and keeps the pass in sync:
  # - first mark as present takes one entry from the participant's oldest pass with entries left,
  # - marking absent again gives that entry back,
  # - saving the same value again changes nothing, so a resubmitted form never charges twice.
  # Must run inside a transaction (Lesson#record_attendance provides one).
  def update_presence!(present)
    return if persisted? && self.present == present

    if present
      self.pass = user.passes.with_entries_left.order(:created_at).lock.first
      pass&.use_entry!
    elsif pass
      pass.lock!.return_entry!
      self.pass = nil
    end

    self.present = present
    save!
  end

  def charged?
    pass_id.present?
  end
end
