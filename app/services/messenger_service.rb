class MessengerService
  def initialize(booking)
    @booking = booking
  end

  def message_new_booking
    conversation = Conversation.find_or_create_by(sender_id: @booking.user_id, recipient_id: @booking.provider_id)

    conversation.messages.create(
      content: "Your booking is now active!",
      user_id: @booking.user_id
    )
  end

  def message_booking_accepted
    conversation = Conversation.find_or_create_by(sender_id: @booking.user_id, recipient_id: @booking.provider_id)

    conversation.messages.create(
      content: "You have a new booking!",
      user_id: @booking.user_id
    )
  end

  def message_booking_rejected
    message = "Your booking has been rejected! "
    send_message(message)
  end

  def message_booking_canceled
    message = "Your booking has been canceled! "
    send_message(message)
  end
end