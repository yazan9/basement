# app/mailers/booking_mailer.rb

class Bookings::BookingMailer < ApplicationMailer
  default from: 'bookings@helpingpixies.com'

  def three_day_reminder(outgoing_message, booking, time_zone = nil)
    @booking = booking
    @converted_booking_time = @booking.start_at.in_time_zone(time_zone || "UTC")
    mail(to: resolve_recipient(outgoing_message.to), subject: 'Reminder: Your booking starts in 3 days')
  end

  def one_day_reminder(outgoing_message, booking, time_zone = nil)
    @booking = booking
    @converted_booking_time = @booking.start_at.in_time_zone(time_zone || "UTC")
    mail(to: resolve_recipient(outgoing_message.to), subject: 'Reminder: Your booking starts tomorrow')
  end

  def notify_new_booking(booking)
    @booking = booking
    mail(to: resolve_recipient(@booking.provider.email), subject: 'Yupee! You have New booking!')
  end

  def notify_booking_accepted(booking)
    @booking = booking
    mail(to: resolve_recipient(@booking.provider.email), subject: 'Booking updated')
  end

  def notify_booking_rejected(booking)
    @booking = booking
    mail(to: resolve_recipient(@booking.user.email), subject: 'Booking declined :( ')
  end

  def notify_booking_cancelled(booking)
    @booking = booking
    mail(to: resolve_recipient(@booking.user.email), subject: 'Booking cancelled')
  end

  def notify_booking_cancellation(booking)
    @booking = booking
    to = @booking.status == 'cancelled_by_client' ? @booking.user.email : @booking.provider.email
    mail(to: resolve_recipient(to), subject: 'Booking cancelled')
  end

  def resolve_link(user)
    "#{ENV.fetch('PIXIES_UI_URL', 'https://helpingpixies.com')}/#{user.user_type == 'client' ? 'dashboard' : 'provider'}"
  end
end
