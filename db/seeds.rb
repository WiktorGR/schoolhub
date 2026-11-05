# Demo data for development and the public demo. Safe to run many times:
# accounts are found or created, and the school data is only created once.

DEMO_PASSWORD = "demo12345"

def demo_user(name, email_address, role = :participant)
  User.find_or_create_by!(email_address: email_address) do |user|
    user.name = name
    user.role = role
    user.password = DEMO_PASSWORD
  end
end

admin = demo_user("Alicja Admin", "admin@schoolhub.test", :admin)
instructor = demo_user("Igor Instruktor", "instruktor@schoolhub.test", :instructor)
second_instructor = demo_user("Natalia Nowicka", "instruktorka@schoolhub.test", :instructor)
participant = demo_user("Ula Uczestniczka", "uczestnik@schoolhub.test")
others = [
  [ "Bartek Bąk", "bartek@schoolhub.test" ],
  [ "Celina Czajka", "celina@schoolhub.test" ],
  [ "Damian Dudek", "damian@schoolhub.test" ],
  [ "Ewelina Erb", "ewelina@schoolhub.test" ],
  [ "Filip Fik", "filip@schoolhub.test" ]
].map { |name, email_address| demo_user(name, email_address) }

if Course.none?
  ActiveRecord::Base.transaction do
    english = Course.create!(name: "Angielski B1", description: "Kurs konwersacyjny dla osób średnio zaawansowanych. Zajęcia w małych grupach.")
    salsa = Course.create!(name: "Salsa od podstaw", description: "Taniec dla początkujących. Nie potrzebujesz partnera.")
    Course.create!(name: "Hiszpański A1", description: "Nowy kurs, grupy wkrótce.")

    english_evening = english.course_groups.create!(name: "Wtorki 18:00", capacity: 3, instructor: instructor)
    english_weekend = english.course_groups.create!(name: "Soboty 10:00", capacity: 8, instructor: second_instructor)
    salsa_group = salsa.course_groups.create!(name: "Czwartki 19:30", capacity: 10, instructor: instructor)

    # Lessons: last week plus the next five weeks, at the same local time each week.
    last_week = Time.zone.today.beginning_of_week - 1.week
    {
      english_evening => [ 1, 18, 0, 90 ],
      english_weekend => [ 5, 10, 0, 90 ],
      salsa_group => [ 3, 19, 30, 60 ]
    }.each do |group, (weekday_offset, hour, minute, minutes)|
      starts_at = (last_week + weekday_offset.days).in_time_zone.change(hour: hour, min: minute)
      Lesson.create_weekly_series({ course_group: group, starts_at: starts_at, ends_at: starts_at + minutes.minutes, topic: nil }, weeks: 6)
    end

    # English evening: 3 seats taken, 2 people on the waitlist.
    [ participant, *others ].each { |user| english_evening.enroll(user) }
    salsa_group.enroll(participant)
    others.first(2).each { |user| salsa_group.enroll(user) }

    [ participant, *others ].each { |user| user.passes.create!(entries_total: 8) }

    # Attendance for last week's lessons, so passes show used entries.
    english_evening.lessons.where(ends_at: ...Time.current).find_each do |lesson|
      lesson.record_attendance(english_evening.enrollments.active.pluck(:user_id).first(2))
    end
  end
end

puts "Demo data ready. Accounts (password: #{DEMO_PASSWORD}):"
[ admin, instructor, second_instructor, participant ].each { |user| puts "  #{user.email_address} (#{user.role})" }
