class SchedulesController < ApplicationController
  def show
    @lessons = paginate(lessons_for(Current.user).upcoming.includes(course_group: %i[ course instructor ]))
  end

  private
    def lessons_for(user)
      if user.admin?
        Lesson.all
      elsif user.instructor?
        Lesson.for_instructor(user)
      else
        Lesson.for_participant(user)
      end
    end
end
