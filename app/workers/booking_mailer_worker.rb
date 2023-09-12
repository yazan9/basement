class BookingMailerWorker
  include Sidekiq::Worker

  def perform(booking_id, action)
    booking = Booking.find(booking_id)

    case action
    when 'new_booking'
      Bookings::BookingMailer.notify_new_booking(booking).deliver_now
    when 'booking_accepted'
      Bookings::BookingMailer.notify_booking_accepted(booking).deliver_now
    when 'booking_rejected'
      Bookings::BookingMailer.notify_booking_rejected(booking).deliver_now
    when 'booking_canceled'
      Bookings::BookingMailer.notify_booking_cancelled(booking).deliver_now
    else
      raise "Invalid action provided to BookingMailerWorker"
    end
  end
end
