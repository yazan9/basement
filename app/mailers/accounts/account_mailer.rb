class Accounts::AccountMailer < ApplicationMailer
  default from: 'accounts@helpingpixies.com'
  def send_email_confirmation(user)
    @user = user
    #mail(to: @user.email, subject: 'Welcome to Helping Pixies! Please confirm your email address by clicking the link below')
  end
end