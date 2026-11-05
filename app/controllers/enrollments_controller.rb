class EnrollmentsController < ApplicationController
  require_role :participant

  def index
    @enrollments = Current.user.enrollments.not_cancelled
                          .includes(course_group: %i[ course instructor ])
                          .order(:created_at)
  end

  def create
    course_group = CourseGroup.find(params.expect(:course_group_id))
    enrollment = course_group.enroll(Current.user)

    if enrollment.persisted?
      EnrollmentMailer.confirmation(enrollment).deliver_later
      redirect_to course_path(course_group.course), notice: enrollment_notice(enrollment)
    else
      redirect_to course_path(course_group.course), alert: enrollment.errors.full_messages.to_sentence
    end
  end

  def destroy
    # Scoped to the current user, so nobody can cancel someone else's enrollment (IDOR).
    enrollment = Current.user.enrollments.find(params.expect(:id))
    enrollment.cancel!.each { |promoted| EnrollmentMailer.promoted(promoted).deliver_later }

    redirect_back_or_to enrollments_path, notice: "Zrezygnowano z zapisu do grupy #{enrollment.course_group.name}.",
                                          status: :see_other
  end

  private
    def enrollment_notice(enrollment)
      if enrollment.active?
        "Masz miejsce w grupie #{enrollment.course_group.name}."
      else
        "Grupa jest pełna. Jesteś na liście rezerwowej (pozycja #{enrollment.waitlist_position})."
      end
    end
end
