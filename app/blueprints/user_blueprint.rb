# app/blueprints/user_blueprint.rb

class UserBlueprint < Blueprinter::Base
  identifier :id
  fields :name
  field :distance_from_origin, name: :distance
end


