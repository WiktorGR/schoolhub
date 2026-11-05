class Course < ApplicationRecord
  has_many :course_groups, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
