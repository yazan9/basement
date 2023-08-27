# app/mailers/test_mailer.rb
class TestMailer < ApplicationMailer
  default from: 'alerts@goblackiris.com'
  def welcome_email
    mail(to: 'yazan@goblackiris.com', subject: 'Welcome to My Awesome Site')
  end
end
