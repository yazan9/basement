class AccountMailerWorker
  include Sidekiq::Worker

  def perform(user_id, action, *args)
    user = User.find(user_id)

    case action
    when 'new_account'
      Accounts::AccountMailer.with(user: user).send_email_confirmation(user).deliver_now
    # when 'booking_update'
    #   AccountMailer.with(user: user).notify_booking_update.deliver_now
    # when 'booking_cancellation'
    #   AccountMailer.with(user: user).notify_booking_cancellation.deliver_now
    else
      raise "Invalid action provided to AccountMailerWorker"
    end
  end
end
