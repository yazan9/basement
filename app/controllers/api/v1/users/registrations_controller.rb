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
    build_resource(sign_up_params.except(:latitude, :longitude))

    # Assign the location using PostGIS's ST_Point method
    if sign_up_params[:latitude].present? && sign_up_params[:longitude].present?
      resource.location = "POINT(#{sign_up_params[:longitude]} #{sign_up_params[:latitude]})"
    end

    if resource.save
      # Generate a JWT token
      jwt_token = generate_jwt_token(resource)

      # Return the JWT token in the response
      render json: { message: 'User created successfully.', jwt_token: jwt_token }, status: :created
    else
      # Handle failed registration
      render json: { message: 'Failed to create user.', errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
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
    params.require(:user).permit(:email, :password, :name, :phone, :user_type, :latitude, :longitude)
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
