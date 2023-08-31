# app/workers/update_booking_slots_worker.rb

class UpdateBookingSlotsWorker
  include Sidekiq::Worker

  def perform(booking_id)
    booking = Booking.find(booking_id)

    return if booking.status != 'active'

    # Delete existing booking slots for this booking
    booking.booking_slots.destroy_all

    days_from_now = 30
    occurrences = NextBookingSlotService.new(booking, days_from_now).call

    occurrences.each do |occurrence|
      booking_slot = BookingSlot.new(
        booking: booking,
        user: booking.user,
        start_at: occurrence,
        end_at: occurrence + booking.hours.hours
      )
      booking_slot.save!
    end
  end
end
