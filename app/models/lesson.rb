class Lesson < ApplicationRecord
  MAX_WEEKS_IN_SERIES = 20

  belongs_to :course_group
  has_many :attendances, dependent: :restrict_with_error

  validates :starts_at, :ends_at, presence: true
  validates :topic, length: { maximum: 200 }
  validate :ends_after_start

  scope :upcoming, -> { where(ends_at: Time.current..).order(:starts_at) }
  scope :for_participant, ->(user) { joins(course_group: :enrollments).merge(Enrollment.active.where(user: user)) }
  scope :for_instructor, ->(user) { joins(:course_group).where(course_groups: { instructor_id: user.id }) }

  # Lessons whose attendance the user may check: admins all, instructors only their own groups.
  def self.manageable_by(user)
    if user.admin?
      all
    elsif user.instructor?
      for_instructor(user)
    else
      none
    end
  end

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

  # Participants listed on the attendance sheet: current seat holders plus anyone
  # who already has an attendance row (e.g. cancelled after the lesson).
  def attendance_roster
    User.where(id: course_group.enrollments.active.select(:user_id))
        .or(User.where(id: attendances.select(:user_id)))
        .order(:name)
  end

  # Saves the attendance sheet in one go. `present_user_ids` are the ticked participants;
  # everyone else on the roster is marked absent. The lesson row lock stops two people
  # saving the same sheet at once from creating duplicate rows or double charges.
  def record_attendance(present_user_ids)
    present_user_ids = Array(present_user_ids).map(&:to_i)

    with_lock do
      existing = attendances.index_by(&:user_id)
      attendance_roster.each do |user|
        attendance = existing[user.id] || attendances.new(user: user)
        attendance.update_presence!(present_user_ids.include?(user.id))
      end
    end
  end

  def started?
    starts_at <= Time.current
  end

  private
    def ends_after_start
      errors.add(:ends_at, :before_start) if starts_at && ends_at && ends_at <= starts_at
    end
end
