class Lesson < ApplicationRecord
  MAX_WEEKS_IN_SERIES = 20

  belongs_to :course_group

  validates :starts_at, :ends_at, presence: true
  validates :topic, length: { maximum: 200 }
  validate :ends_after_start

  scope :upcoming, -> { where(ends_at: Time.current..).order(:starts_at) }
  scope :for_participant, ->(user) { joins(course_group: :enrollments).merge(Enrollment.active.where(user: user)) }
  scope :for_instructor, ->(user) { joins(:course_group).where(course_groups: { instructor_id: user.id }) }

  # Builds the same lesson every week, e.g. "Tuesdays 18:00-19:30 for 10 weeks".
  # Saves all lessons or none; returns the first lesson with any validation errors.
  def self.create_weekly_series(attributes, weeks:)
    weeks = weeks.to_i.clamp(1, MAX_WEEKS_IN_SERIES)
    first = new(attributes)

    transaction do
      weeks.times do |week|
        lesson = new(attributes)
        lesson.starts_at += week.weeks if lesson.starts_at
        lesson.ends_at += week.weeks if lesson.ends_at
        lesson.save!
      end
    end
    first
  rescue ActiveRecord::RecordInvalid => e
    first.errors.merge!(e.record.errors)
    first
  end

  private
    def ends_after_start
      errors.add(:ends_at, :before_start) if starts_at && ends_at && ends_at <= starts_at
    end
end
