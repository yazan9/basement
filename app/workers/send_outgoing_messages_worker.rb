# app/workers/send_email_worker.rb
class SendOutgoingMessagesWorker
  include Sidekiq::Worker

  def perform
    OutgoingMessage.where(status: 'queued').find_each(batch_size: 100) do |message|
      status, error_message = send_email(message)
      message.update(status: status, error_message: error_message)
      sleep 2
    end
    sleep 60
  end

  private

  def send_email(message)
    message_type = message.message_type.to_sym
    case message_type
    when :three_day_reminder
      Bookings::BookingMailer.three_day_reminder(
        message, Booking.find(message['data']['booking_id']), message['data']['timezone']).deliver!
    when :one_day_reminder
      Bookings::BookingMailer.one_day_reminder(
        message, Booking.find(message['data']['booking_id']), message['data']['timezone']).deliver!
    else
      ["failed", "Unknown message type: #{message_type}"]
    end
    ["sent", nil]
  rescue => e
    ["failed", e.message]
  end
end
