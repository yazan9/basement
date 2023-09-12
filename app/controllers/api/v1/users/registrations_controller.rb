# frozen_string_literal: true

class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  include JwtAuthentication
  skip_before_action :authenticate_from_token!, only: [:create]

  # GET /resource/sign_up
  def new
    super
  end

  def create
    #TODO: Move to a background job since this is taking a long time to reverse geocode and send confirmation email
    start_time = Time.now

    build_resource(sign_up_params.except(:latitude, :longitude))
    puts "Time taken to build resource: #{Time.now - start_time}s"
    segment_start_time = Time.now

    # Geocoding to find latitude and longitude from postal code
    if sign_up_params[:address].present?
      coordinates = Geocoder.coordinates(sign_up_params[:address])
      if coordinates.present?
        latitude, longitude = coordinates
        # Using PostGIS's ST_Point method to store lat, long
        resource.location = "POINT(#{longitude} #{latitude})"
        resource.address_verified = true
      end
    end

    # Log time taken for setting coordinates and checking validity
    puts "Time taken for setting coordinates and checking validity: #{Time.now - segment_start_time}s"

    segment_start_time = Time.now
    if resource.save
      render json: { message: 'User created successfully, Please confirm your email address.' }, status: :created
    else
      # Handle failed registration
      render json: { message: 'Failed to create user.', errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
    # Log time taken for resource.save and rendering
    puts "Time taken for resource.save and rendering: #{Time.now - segment_start_time}s"

    # Log total time taken for the entire action
    puts "Total time taken: #{Time.now - start_time}s"
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected
  def sign_up_params
    params.require(:user).permit(:email, :password, :name, :phone, :user_type, :latitude, :longitude, :address)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
