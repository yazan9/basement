class Booking < ApplicationRecord
  attr_accessor :accepted
  attr_accessor :rejected
  attr_accessor :canceled

  belongs_to :user
  belongs_to :provider, class_name: 'User', foreign_key: 'provider_id'

  has_many :booking_slots, dependent: :destroy

  validates :start_at, presence: true
  validates :frequency, presence: true
  validates :status, presence: true

  after_commit :queue_update_booking_slots
  after_commit :update_booking_slots_immediately, on: :update

  after_commit -> { BookingMailerWorker.perform_async(self.id, 'new_booking') }, on: :create
  after_commit -> { email_parties }, on: :update


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

  def email_parties
    if self.accepted
      BookingMailerWorker.perform_async(self.id, 'booking_accepted')
    elsif self.rejected
      BookingMailerWorker.perform_async(self.id, 'booking_rejected')
    elsif self.canceled
      BookingMailerWorker.perform_async(self.id, 'booking_canceled')
    end
  end

  def queue_update_booking_slots
    UpdateBookingSlotsWorker.perform_async(self.id)
  end

  def update_booking_slots_immediately
    if self.status == 'active'
      create_booking_slots
    else
      if self.status == 'cancelled_by_client' || self.status == 'cancelled_by_provider'
        clear_booking_slots
      end
    end
  end

  def create_booking_slots
    days_from_now = 60
    occurrences = NextBookingSlotService.new(self, days_from_now).call

    occurrences.each do |occurrence|
      booking_slot = BookingSlot.new(
        booking: self,
        user: self.provider,
        start_at: occurrence,
        end_at: occurrence + self.hours.hours
      )
      booking_slot.save!
    end
  end

  def clear_booking_slots
    self.booking_slots.destroy_all
  end
end
