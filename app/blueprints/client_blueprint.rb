# app/blueprints/user_blueprint.rb
class ClientBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :profile_image_url

  view :show do
    fields :average_rating
  end
end