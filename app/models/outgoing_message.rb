class OutgoingMessage < ApplicationRecord

  enum message_type: {
    three_day_reminder: 0,
    one_day_reminder: 1
  }

  enum status: {
    queued: 0,
    sent: 1,
    failed: 2
  }

  enum platform: {
    email: 0,
    sms: 1,
    push_notification: 2
  }
end