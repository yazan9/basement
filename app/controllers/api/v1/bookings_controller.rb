class Api::V1::BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :update, :destroy]
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
    @booking.destroy
    render status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_booking
    @booking = Booking.find_by(id: params[:id], user_id: @api_user.id)
  end

  def set_bookings
    @bookings = Booking.where(user_id: @api_user.id)
  end

  # Only allow a list of trusted parameters through.
  def booking_params
    params.require(:booking).permit(:provider_id, :start_at, :frequency, :rate, :comments).merge(user_id: @api_user.id)
  end
end
