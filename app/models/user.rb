class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :enrollments, dependent: :restrict_with_error
  has_many :taught_course_groups, class_name: "CourseGroup", foreign_key: :instructor_id,
                                  inverse_of: :instructor, dependent: :restrict_with_error

  enum :role, { participant: 0, instructor: 1, admin: 2 }, default: :participant, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  # allow_nil skips the check when the password is not being changed.
  validates :password, length: { minimum: 8 }, allow_nil: true
end
