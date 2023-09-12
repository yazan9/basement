# app/mailers/booking_mailer.rb

class Bookings::BookingMailer < ApplicationMailer
  default from: 'bookings@helpingpixies.com'

  def resolve_recipient(original_email)
    ENV['OVERRIDE_EMAIL_RECIPIENT'] || original_email
  end

  def three_day_reminder(booking)
    @booking = booking
    mail(to: resolve_recipient(@booking.user.email), subject: 'Reminder: Your booking starts in 3 days')
  end

  def one_day_reminder(booking)
    @booking = booking
    mail(to: resolve_recipient(@booking.user.email), subject: 'Reminder: Your booking starts tomorrow')
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
end
