class CourseGroup < ApplicationRecord
  belongs_to :course
  belongs_to :instructor, class_name: "User", inverse_of: :taught_course_groups

  validates :name, presence: true, uniqueness: { scope: :course_id }, length: { maximum: 100 }
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }
  validate :instructor_must_be_an_instructor

  private
    def instructor_must_be_an_instructor
      errors.add(:instructor, :not_an_instructor) if instructor && !instructor.instructor?
    end
end
