class ListingBlueprint < Blueprinter::Base
  identifier :id

  fields :user_id, :provider_id
  fields :status, :rate, :comments, :created_at, :updated_at

  # include associated user with key 'client'
  #association :user, blueprint: OwnerBlueprint, name: :client
end