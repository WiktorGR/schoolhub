class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "SchoolHub <no-reply@schoolhub.example>")
  layout "mailer"
end
