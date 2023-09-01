class BookingMailerWorker
  include Sidekiq::Worker

  def perform(booking_id, action)
    booking = Booking.find(booking_id)

    case action
    when 'new_booking'
      BookingMailer.with(booking: booking).notify_new_booking.deliver_now
    when 'booking_update'
      BookingMailer.with(booking: booking).notify_booking_update.deliver_now
    when 'booking_cancellation'
      BookingMailer.with(booking: booking).notify_booking_cancellation.deliver_now
    else
      raise "Invalid action provided to BookingMailerWorker"
    end
  end
end
