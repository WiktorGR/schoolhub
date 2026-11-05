require "test_helper"

class EnrollmentMailerTest < ActionMailer::TestCase
  test "confirmation for a seat" do
    enrollment = enrollments(:one_in_english_evening)

    mail = EnrollmentMailer.confirmation(enrollment)

    assert_equal [ "one@example.com" ], mail.to
    assert_equal "Potwierdzenie zapisu: Angielski B1, Wtorki 18:00", mail.subject
    assert_match "masz miejsce w grupie", mail.text_part.body.to_s
  end

  test "confirmation for a waitlist place mentions the position" do
    course_groups(:english_evening).enroll(users(:two))
    waitlisted = course_groups(:english_evening).enroll(users(:three))

    mail = EnrollmentMailer.confirmation(waitlisted)

    assert_equal "Lista rezerwowa: Angielski B1, Wtorki 18:00", mail.subject
    assert_match "listy rezerwowej (pozycja 1)", mail.text_part.body.to_s
  end

  test "promoted" do
    mail = EnrollmentMailer.promoted(enrollments(:one_in_english_evening))

    assert_equal "Zwolniło się miejsce: Angielski B1, Wtorki 18:00", mail.subject
    assert_match "Miejsce jest już Twoje", mail.html_part.body.to_s
  end
end
