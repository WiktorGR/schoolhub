class CoursesController < ApplicationController
  def index
    @courses = paginate(Course.order(:name))
  end

  def show
    @course = Course.find(params.expect(:id))
    @course_groups = @course.course_groups.includes(:instructor).order(:name)
  end
end
