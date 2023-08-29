# frozen_string_literal: true

class Api::V1::Users::PasswordsController < Devise::PasswordsController
  skip_before_action :authenticate_from_token!, only: [:create, :update]

  # GET /resource/password/new
  # def new
  #   super
  # end

  #POST /resource/password
  def create
    user = User.find_by(email: create_params[:email])

    if user.nil?
      render json: { message: 'Failed to send reset password instructions.', code: 0 }, status: :unprocessable_entity and return
    end

    user&.send_reset_password_instructions
    if successfully_sent?(user)
      render json: { message: 'Reset password instructions sent successfully.', code: 1 }, status: :ok
    else
      render json: { message: 'Failed to send reset password instructions.', code: 2 }, status: :unprocessable_entity
    end
  end

  def update
    # find user by reset_password_token
    user = User.find_by(reset_password_token: params[:reset_password_token])

    if user&.reset_password_period_valid?
      # update password
      user.password = params[:password]

      if user.save
        render json: { message: "Password updated successfully" }, status: :ok
      else
        render json: { error: user.errors.full_messages, code: 0 }, status: :unprocessable_entity
      end
    else
      render json: { error: "Invalid token or token has expired", code: 1 }, status: :unprocessable_entity
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected
  def create_params
    params.require(:user).permit(:email)
  end

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
