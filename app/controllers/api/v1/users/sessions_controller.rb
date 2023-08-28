# frozen_string_literal: true

class Api::V1::Users::SessionsController < Devise::SessionsController
  include JwtAuthentication
  skip_before_action :authenticate_from_token!, only: [:create]

  respond_to :json

  # POST /api/v1/users/sign_in
  def create
    user = User.find_by(email: params[:user][:email])
    if user&.valid_password?(params[:user][:password])
      if user.confirmed_at.nil?
        render json: { message: 'Please confirm your email address.' }, status: :unauthorized and return
      end
      sign_in(user)
      # Generate a JWT token
      jwt_token = generate_jwt_token(user)
      render json: { message: 'Signed in successfully.', user: UserBlueprint.render_as_hash(user, view: :restricted), jwt_token: jwt_token }, status: :ok
    else
      render json: { message: 'Invalid email or password.' }, status: :unauthorized
    end
  end

  # DELETE /api/v1/users/sign_out
  def destroy
    if current_user
      sign_out(current_user)
      render json: { message: 'Signed out successfully.' }, status: :ok
    else
      render json: { message: 'User not found.' }, status: :not_found
    end
  end
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
