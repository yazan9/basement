class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers
  prepend_before_action :authenticate_from_token!

  def authenticate_from_token!
    find_user_from_auth_token
    render json: { error: 'Authentication failed.' }, status: :unauthorized if @api_user.blank?
  rescue Exception => e
    render json: { error: 'Authentication failed.' }, status: :unauthorized
  end

  def find_user_from_auth_token
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].gsub('Bearer ', '')
      @api_user = (User.authenticate_from_jwt_token!(token) rescue nil)
      Rails.logger.debug('---- Auth Header ----')
      Rails.logger.debug(request.headers['Authorization'])
      Rails.logger.debug("User: #{@api_user&.id || 'none'}")
    else
      @api_user = User.authenticate_from_token!(params[:sid], params[:auth_token])
    end
  end
end
