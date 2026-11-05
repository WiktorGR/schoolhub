class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { participant: 0, instructor: 1, admin: 2 }, default: :participant, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
