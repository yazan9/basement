class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates_presence_of :content, :conversation_id, :user_id
  def the_other_user(user)
    self.conversation.the_other_user(user)
  end
end
