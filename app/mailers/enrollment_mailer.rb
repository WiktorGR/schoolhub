class EnrollmentMailer < ApplicationMailer
  # Sent right after enrolling, both for a seat and for a waitlist place.
  def confirmation(enrollment)
    @enrollment = enrollment
    @course_group = enrollment.course_group
    subject = enrollment.waitlisted? ? "Lista rezerwowa" : "Potwierdzenie zapisu"

    mail to: enrollment.user.email_address, subject: "#{subject}: #{@course_group.course.name}, #{@course_group.name}"
  end

  # Sent when a seat frees up and the participant moves from the waitlist.
  def promoted(enrollment)
    @enrollment = enrollment
    @course_group = enrollment.course_group

    mail to: enrollment.user.email_address,
         subject: "Zwolniło się miejsce: #{@course_group.course.name}, #{@course_group.name}"
  end
end
