class Api::V1::SearchController < ApplicationController
  include PaginationConcern
  skip_before_action :authenticate_from_token!, only: [:index, :show]
  def index
    #render json: debug and return
    # Ensure required parameters are present
    if params[:latitude].present? && params[:longitude].present? && params[:radius].present?
      lat = params[:latitude].to_f
      lon = params[:longitude].to_f
      radius_in_km = params[:radius].to_f
      radius_in_meters = radius_in_km * 1000  # Convert km to meters
      query = params[:query]

      # Fetch users of type 1 within the specified radius
      # Caution: SQL injection vulnerability - minimized by to_f conversion above
      users_scope = User.select("users.*, floor(ST_Distance(location, ST_MakePoint(#{lon}, #{lat})::geography)/1000) as distance_from_origin")
                        .where(user_type: :provider)
                        .where("ST_DWithin(location, ST_MakePoint(?, ?)::geography, ?)", lon, lat, radius_in_meters)
                        .order("distance_from_origin ASC")

      # If a query parameter is provided, filter by name and description
      if query.present?
        #users_scope = users_scope.where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
        users_scope = users_scope.where("name ILIKE ?", "%#{query}%")
      end

      #filter by availablity
      hours = params[:hours].present? ? params[:hours].to_i : 0
      start_at = params[:start_at].present? ? DateTime.parse(params[:start_at]) : nil
      frequency = params[:frequency]

      if start_at.present?
        end_at = start_at + hours.hours

        users_scope = users_scope.left_outer_joins(:booking_slots)

        # SQL condition to find overlapping bookings
        condition_overlap = "((? <= booking_slots.start_at AND ? >= booking_slots.end_at) OR " \
                    "(? >= booking_slots.start_at AND ? <= booking_slots.end_at) OR " \
                    "(? >= booking_slots.start_at AND ? <= booking_slots.end_at))"

        # Apply the condition and filter
        users_scope = users_scope.where(
          "booking_slots.id IS NULL OR NOT EXISTS (" \
          "SELECT 1 FROM booking_slots " \
          "WHERE booking_slots.user_id = users.id AND #{condition_overlap}" \
          ")",
          start_at, end_at,
          start_at, start_at,
          end_at, end_at
        ).distinct
      end

      # Render paginated users
      render json: { users: UserBlueprint.render_as_hash(paginate(users_scope), view: :extended), meta: pagination_status }, status: :ok
    else
      render json: { error: 'Missing required parameters' }, status: :bad_request
    end
  end

  def debug
    booking = Booking.find(8)
    days_from_now = 4
    next_booking_slot_service = NextBookingSlotService.new(booking, days_from_now)
    next_booking_slot_service.call
  end
end
