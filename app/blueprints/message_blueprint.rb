class MessageBlueprint < Blueprinter::Base
  identifier :id
  field :content
  field :created_at
  field :updated_at
  field :user_id
  field :conversation_id
  field :sender do |message|
    puts message.user.name
    message.user.name
  end
end
