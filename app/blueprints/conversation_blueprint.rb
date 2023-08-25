class ConversationBlueprint < Blueprinter::Base
  identifier :id
  field :sender_id, name: :initiator_id
  field :recipient_id
  field :created_at
  field :updated_at
  field :last_message do |conversation, options|
    MessageBlueprint.render_as_hash(conversation.messages.last, options)
  end
  field :the_other_user do |conversation, options|
    UserBlueprint.render_as_hash(conversation.the_other_user(options[:current_user]), view: :in_messages)
  end
  field :unread_messages_count do |conversation, options|
    conversation.unread_messages_count(options[:current_user])
  end
end