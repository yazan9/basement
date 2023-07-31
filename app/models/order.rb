class Order < ApplicationRecord
  enum frequency: {
    one_time: 0,
    daily: 1,
    twice_a_week: 2,
    weekly: 3,
    every_two_weeks: 4,
    monthly: 5
  }

  enum status: {
    in_progress: 0,
    completed: 1
  }
end
