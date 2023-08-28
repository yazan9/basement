# frozen_string_literal: true

class Api::V1::Users::ConfirmationsController < Devise::ConfirmationsController
  skip_before_action :authenticate_from_token!, only: [:show, :create]

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  def create
    self.resource = User.find_by(email: params[:email])

    if resource.nil?
      render json: { message: 'Failed to send confirmation email.', code: 0 }, status: :unprocessable_entity and return
    end

    yield resource if block_given?

    resource.send_confirmation_instructions

    if successfully_sent?(resource)
      render json: { message: 'Confirmation email sent successfully.', code: 1 }, status: :ok
    else
      render json: { message: 'Failed to send confirmation email.', code: 2 }, status: :unprocessable_entity
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      render json: { message: 'Email confirmed successfully.' }, status: :ok
    else
      render json: { message: 'Invalid confirmation token.' }, status: :unauthorized
    end
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
