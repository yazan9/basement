class BookingSlot < ApplicationRecord
  belongs_to :user
  belongs_to :booking

  validates :start_at, presence: true
  validates :end_at, presence: true
end