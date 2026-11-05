class CoursesController < ApplicationController
  def index
    @courses = paginate(Course.order(:name))
  end

  def show
    @course = Course.find(params.expect(:id))
    @course_groups = @course.course_groups.includes(:instructor).order(:name)
    # One query each instead of one per group (avoids N+1 on the list).
    @seats_taken = Enrollment.active.where(course_group: @course_groups).group(:course_group_id).count
    @my_enrollments = Current.user.enrollments.not_cancelled.where(course_group: @course_groups).index_by(&:course_group_id)
  end
end
