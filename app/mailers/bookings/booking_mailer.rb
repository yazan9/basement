# app/mailers/booking_mailer.rb
class Bookings::BookingMailer < ApplicationMailer
  def three_day_reminder(booking)
    @booking = booking
    mail(to: @booking.user.email, subject: 'Reminder: Your booking starts in 3 days')
  end

  def one_day_reminder(booking)
    @booking = booking
    mail(to: @booking.user.email, subject: 'Reminder: Your booking starts tomorrow')
  end

  def notify_new_booking(booking)
    @booking = booking
    mail(to: @booking.provider.email, subject: 'Yupee! You have New booking!')
  end

  def notify_booking_update(booking)
    @booking = booking
    mail(to: @booking.provider.email, subject: 'Booking updated')
    mail(to: @booking.user.email, subject: 'Booking updated')
  end

  def notify_booking_cancellation(booking)
    @booking = booking
    to = @booking.status == 'cancelled_by_client' ? @booking.user.email : @booking.provider.email
    mail(to: to, subject: 'Booking cancelled')
  end

end