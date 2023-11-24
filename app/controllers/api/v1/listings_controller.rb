class Api::V1::ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :update, :destroy, :accept]
  before_action :set_listings, only: [:index]

  # GET /listings
  def index
    render json: @listings
  end

  # GET /listing/1
  def show
    render json: @listing
  end

  # POST /listings
  def create
    @listing = Listing.new(listing_params)

    if @listing.save
      render json: @listing, status: :created
    else
      render json: { error: @listing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /listings/1
  def update
    if @listing.update(listing_params)
      render json: @listing, status: :ok
    else
      render json: { error: @listing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /listings/1
  def destroy
    if @listing.destroy
      render json: @listing, status: :ok
    else
      render json: { error: @listing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  #TODO: ADD filter for active/inactive
  def set_listing
    @listing = Listing.find_by(id: params[:id])
  end

  def set_user_listing
    @listing = Listing.find_by(id: params[:id], user_id: @api_user.id)
  end

  def set_listings
    @listings = Listing.where(user_id: @api_user.id)
  end

  # Only allow a list of trusted parameters through.
  def listing_params
    params.require(:listing).permit(:rate, :title, :description, :status).merge(user_id: @api_user.id)
  end
end
