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
end
