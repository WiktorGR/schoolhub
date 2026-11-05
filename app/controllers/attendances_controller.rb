class AttendancesController < ApplicationController
  require_role :admin, :instructor
  before_action :set_lesson

  def edit
    @roster = @lesson.attendance_roster
    @attendances = @lesson.attendances.index_by(&:user_id)
    # One query for everyone's remaining entries instead of one per participant.
    @entries_left = Pass.where(user: @roster).group(:user_id).sum(:entries_remaining)
  end

  def update
    @lesson.record_attendance(params.fetch(:present_user_ids, []))

    redirect_to edit_lesson_attendance_path(@lesson), notice: update_notice
  end

  private
    # Instructors only find lessons of their own groups; anything else is a 404,
    # so lesson ids from other groups cannot be probed.
    def set_lesson
      @lesson = Lesson.manageable_by(Current.user).includes(course_group: :course).find(params.expect(:lesson_id))
    end

    def update_notice
      uncharged = @lesson.attendances.where(present: true, pass: nil).count
      notice = "Obecność została zapisana."
      notice += " Bez wejść na karnecie: #{uncharged}." if uncharged.positive?
      notice
    end
end
