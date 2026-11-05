class SchedulesController < ApplicationController
  def show
    @lessons = paginate(lessons_for(Current.user).upcoming.includes(course_group: %i[ course instructor ]))
    # Staff check attendance after a lesson, so they also see the last week.
    unless Current.user.participant?
      @recent_lessons = lessons_for(Current.user).where(ends_at: 7.days.ago...Time.current)
                                                 .includes(course_group: %i[ course instructor ])
                                                 .order(starts_at: :desc)
    end
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
