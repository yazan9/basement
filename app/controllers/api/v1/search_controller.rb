class Api::V1::SearchController < ApplicationController
  include PaginationConcern
  def index
    # Ensure required parameters are present
    if params[:latitude].present? && params[:longitude].present? && params[:radius].present?
      lat = params[:latitude].to_f
      lon = params[:longitude].to_f
      radius_in_km = params[:radius].to_f
      radius_in_meters = radius_in_km * 1000  # Convert km to meters

      # Fetch users of type 1 within the specified radius
      # Caution: SQL injection vulnerability - minimized by to_f conversion above
      users_scope = User.select("users.*, floor(ST_Distance(location, ST_MakePoint(#{lon}, #{lat})::geography)/1000) as distance_from_origin")
                        .where(user_type: :provider)
                        .where("ST_DWithin(location, ST_MakePoint(?, ?)::geography, ?)", lon, lat, radius_in_meters)
                        .order("distance_from_origin ASC")

      # Render paginated users
      render json: { users: UserBlueprint.render_as_hash(paginate(users_scope)), meta: pagination_status }, status: :ok
    else
      render json: { error: 'Missing required parameters' }, status: :bad_request
    end
  end

end
