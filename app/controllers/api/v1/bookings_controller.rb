class Api::V1::BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :update, :destroy, :accept]
  before_action :set_bookings, only: [:index]

  # GET /bookings
  def index
    render json: @bookings
  end

  # GET /bookings/1
  def show
    render json: @booking
  end

  # POST /bookings
  def create
    @booking = Booking.new(booking_params)
    @booking.status = :pending

    if @booking.save
      render json: @booking, status: :created
    else
      render json: { error: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bookings/1
  def update
    if @booking.update(booking_params)
      render json: @booking, status: :ok
    else
      render json: { error: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /bookings/1
  def destroy
    if @api_user.user_type == "client"
      @booking.status = :cancelled_by_client
    else
      @booking.status = :cancelled_by_provider
    end

    if @booking.save
      render json: @booking, status: :ok
    else
      render json: { error: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def accept
    @booking.status = :active

    if @booking.save!
      render json: @booking, status: :ok
    else
      render json: { error: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_booking
    if @api_user.user_type == 'provider'
      set_booking_for_provider
    else
      set_booking_for_client
    end
  end

  def set_booking_for_provider
    @booking = Booking.find_by(id: params[:id], provider_id: @api_user.id)
  end

  def set_booking_for_client
    @booking = Booking.find_by(id: params[:id], user_id: @api_user.id)
  end

  def set_bookings
    if @api_user.user_type == 'provider'
      set_bookings_for_provider
    else
      set_bookings_for_client
    end
  end

  def set_bookings_for_provider
    @bookings = Booking.where(provider_id: @api_user.id, status: [:pending, :active]).includes(:provider).map do |booking|
      booking_json = booking.as_json(include: { user: { only: [:id, :name] } })
      booking_json["client"] = booking_json.delete("user")
      booking_json
    end
  end

  def set_bookings_for_client
    @bookings = Booking.where(user_id: @api_user.id, status: [:pending, :active]).includes(:provider).map do |booking|
      booking.as_json(include: { provider: { only: [:id, :name] } }) # Include desired provider attributes
    end
  end

  # Only allow a list of trusted parameters through.
  def booking_params
    params.require(:booking).permit(:provider_id, :start_at, :frequency, :rate, :comments, :offset, :hours).merge(user_id: @api_user.id)
  end
end
