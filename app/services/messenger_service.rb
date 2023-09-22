class MessengerService
  def initialize(booking)
    @booking = booking
  end

  def message_new_booking
    conversation = Conversation.find_or_create_by(sender_id: @booking.user_id, recipient_id: @booking.provider_id)

    conversation.messages.create(
      content: "Your booking is now created!",
      user_id: @booking.user_id,
      is_system_message: true
    )
  end

  def message_booking_accepted
    conversation = Conversation.find_or_create_by(sender_id: @booking.user_id, recipient_id: @booking.provider_id)

    conversation.messages.create(
      content: "Your booking is now accepted",
      user_id: @booking.user_id,
      is_system_message: true
    )
  end

  def message_booking_rejected
    conversation = Conversation.find_or_create_by(sender_id: @booking.user_id, recipient_id: @booking.provider_id)

    conversation.messages.create(
      content: "Your booking has been rejected :(",
      user_id: @booking.user_id,
      is_system_message: true
    )
  end

  def message_booking_canceled
    conversation = Conversation.find_or_create_by(sender_id: @booking.user_id, recipient_id: @booking.provider_id)

    conversation.messages.create(
      content: "Your booking has been cancelled",
      user_id: @booking.user_id,
      is_system_message: true
    )
  end
end