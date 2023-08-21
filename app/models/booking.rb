class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :provider, class_name: 'User', foreign_key: 'provider_id'

  validates :start_at, presence: true
  validates :frequency, presence: true
  validates :status, presence: true

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
    cancelled_by_provider: 4,
  }
end
