class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :provider, class_name: 'User', foreign_key: 'provider_id'

  has_many :booking_slots, dependent: :destroy

  validates :start_at, presence: true
  validates :frequency, presence: true
  validates :status, presence: true

  after_save :update_booking_slots

  enum frequency: {
    once: 0,
    once_a_week: 1,
    twice_a_week: 2,
    once_every_two_weeks: 3,
  }

  enum status: {
    inactive: 0,
    pending: 1,
    active: 2,
    cancelled_by_client: 3,
    cancelled_by_provider: 4
  }

  def update_booking_slots
    # Delete existing booking slots for this booking
    booking_slots.destroy_all

    if self.status != 'active'
      return
    end

    days_from_now = 30
    next_booking_slot_service = NextBookingSlotService.new(self, days_from_now)
    occurrences = next_booking_slot_service.call
    occurrences.each do |occurrence|
      booking_slot = BookingSlot.new(
        booking: self,
        user: self.user,
        start_at: occurrence,
        end_at: occurrence + self.hours.hours
      )
      booking_slot.save!
    end
  end
end
