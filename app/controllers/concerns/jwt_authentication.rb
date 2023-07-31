# app/controllers/concerns/jwt_authentication.rb

module JwtAuthentication
  extend ActiveSupport::Concern

  included do
    private

    def generate_jwt_token(user)
      secret_key = Rails.application.secrets.secret_key_base
      payload = { user_id: user.id }
      expiration = 1.hour.from_now.to_i

      JWT.encode(payload, secret_key, 'HS256', exp: expiration)
    end
  end
end
