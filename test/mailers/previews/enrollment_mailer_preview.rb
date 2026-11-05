# Preview all emails at http://localhost:3000/rails/mailers/enrollment_mailer
class EnrollmentMailerPreview < ActionMailer::Preview
  def confirmation
    EnrollmentMailer.confirmation(Enrollment.active.take || Enrollment.take)
  end

  def confirmation_waitlisted
    EnrollmentMailer.confirmation(Enrollment.waitlisted.take || Enrollment.take)
  end

  def promoted
    EnrollmentMailer.promoted(Enrollment.active.take || Enrollment.take)
  end
end
