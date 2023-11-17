# app/workers/queue_email_worker.rb
require 'sidekiq'
class QueueOutgoingMessageWorker
  include Sidekiq::Worker

  def perform
    puts "QueueOutgoingMessageWorker: perform"
    # Queue reminders 3 days before start_date
    BookingSlot.where('start_at < ?', 3.days.from_now).each do |booking_slot|
      booking = booking_slot.booking
      queue_message(booking.user.email, :three_day_reminder, booking_params(booking, :user))
      queue_message(booking.provider.email, :three_day_reminder, booking_params(booking, :provider))
    end

    # Queue reminders 1 day before start_date
    BookingSlot.where('start_at < ?', 1.days.from_now).each do |booking_slot|
      booking = booking_slot.booking
      queue_message(booking.user.email, :one_day_reminder,  booking_params(booking, :user))
      queue_message(booking.provider.email, :one_day_reminder,  booking_params(booking, :provider))
    end
  end

  private

  def booking_params(booking, user_type = :provider)
    {
      status: 'queued',
      platform: 'email',
      data: { booking_id: booking.id, timezone: user_type == :provider ? booking.provider.time_zone : booking.user.time_zone },
      content: 'standard'
    }
  end

  def queue_message(to, message_type, options = {})
    OutgoingMessage.create!(
      message_type: message_type.to_s,
      to: to,
      status: options[:status],
      platform: options[:platform],
      content: message_type.to_s,
      data: options[:data]
    )
  end
end
