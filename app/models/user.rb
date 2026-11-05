class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { participant: 0, instructor: 1, admin: 2 }, default: :participant, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  # allow_nil skips the check when the password is not being changed.
  validates :password, length: { minimum: 8 }, allow_nil: true
end
