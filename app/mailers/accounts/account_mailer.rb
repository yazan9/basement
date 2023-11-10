class Accounts::AccountMailer < ApplicationMailer
  default from: 'accounts@helpingpixies.com'
  def send_email_confirmation(user)
    @user = user
    @encoded_image = Base64.encode64(File.binread(Rails.root.join("public/logo.png"))).gsub("\n", '')
    @link = "#{ENV.fetch('PIXIES_UI_URL', 'https://helpingpixies.com')}/do-confirm-email?confirmation_token=#{user.confirmation_token}"
    mail(to: user.email, subject: 'Welcome to Helping Pixies! Please confirm your email address by clicking the link below')
  end
end