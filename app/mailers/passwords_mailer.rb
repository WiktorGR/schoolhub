class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Reset hasła w SchoolHub", to: user.email_address
  end
end
