# app/blueprints/user_blueprint.rb

class UserBlueprint < Blueprinter::Base
  identifier :id

  view :restricted do
    fields :email, :name, :profile_image_url, :user_type, :created_at, :updated_at, :phone
  end

  view :extended do
    fields :name, :average_rating, :ratings_count, :profile_image_url
    field :distance_from_origin, name: :distance
  end
end


