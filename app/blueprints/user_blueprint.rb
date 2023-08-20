# app/blueprints/user_blueprint.rb

class UserBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :average_rating, :ratings_count
  field :distance_from_origin, name: :distance
end


