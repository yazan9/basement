class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  def resolve_recipient(original_email)
    ENV['OVERRIDE_EMAIL_RECIPIENT'] || original_email
  end
end
