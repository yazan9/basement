class Conversation < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  has_many :messages, dependent: :destroy

  # Ensure that the combination of sender_id and recipient_id is unique
  validates_uniqueness_of :sender_id, scope: :recipient_id

  scope :between, -> (sender_id, recipient_id) do
    where("(conversations.sender_id = ? AND conversations.recipient_id = ?) OR (conversations.sender_id = ? AND conversations.recipient_id = ?)", sender_id, recipient_id, recipient_id, sender_id)
  end

  def the_other_user(user)
    self.sender == user ? self.recipient : self.sender
  end

  def unread_messages_count(user)
    self.messages.where("user_id != ? AND read = ?", user.id, false).count
  end
end
