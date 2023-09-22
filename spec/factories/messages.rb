FactoryBot.define do
  factory :message do
    body { "Hello, World!" }
    read { false }
    association :user, factory: :user
    association :conversation, factory: :conversation
  end
end