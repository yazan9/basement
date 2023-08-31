# app/workers/queue_email_worker.rb
require 'sidekiq'
class QueueOutgoingMessageWorker
  include Sidekiq::Worker

  def perform
    puts "QueueOutgoingMessageWorker: perform"
    # Queue reminders 3 days before start_date
    # TODO: DO NOT FORGET TO CHANGE THE CONDITION TO 3 DAYS
    Booking.where(start_date: 3.days.from_now.to_date).each do |booking|
      message_params = booking_params(booking)
      queue_message(booking.user.email, :three_day_reminder, message_params)
      queue_message(booking.provider.email, :three_day_reminder, message_params)
    end

    # Queue reminders 1 day before start_date
    Booking.where(start_date: 1.day.from_now.to_date).each do |booking|
      message_params = booking_params(booking)
      queue_message(booking.user.email, :one_day_reminder, message_params)
      queue_message(booking.provider.email, :one_day_reminder, message_params)
    end
  end

  private

  def booking_params(booking)
    {
      status: 'queued',
      platform: 'email',
      data: { booking_id: booking.id },
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
