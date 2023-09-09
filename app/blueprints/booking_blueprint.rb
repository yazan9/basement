class BookingBlueprint < Blueprinter::Base
  identifier :id

  fields :user_id, :provider_id
  fields :frequency, :status, :start_at, :rate, :comments, :created_at, :updated_at, :offset, :hours

  # include associated provider
  association :provider, blueprint: ProviderBlueprint, name: :provider

  # include associated user with key 'client'
  association :user, blueprint: ClientBlueprint, name: :client
end