class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :reviews_given, class_name: 'Review', foreign_key: 'user_id'
  has_many :reviews_received, class_name: 'Review', foreign_key: 'reviewee_id'

  enum user_type: {
    client: 0,
    provider: 1
  }

  def self.authenticate_from_jwt_token!(jwt_token)
    user = User.find_by(id: User.decode_jwt_token(jwt_token)[0]['user_id'])

    if user.present? #&& user.try(:jwt_token) == jwt_token
      user
    else
      raise StandardError('Token not valid')
    end
  end

  def self.decode_jwt_token(user_token)
    key_base_token = Rails.application.secrets.secret_key_base
    leeway = 30
    JWT.decode user_token, key_base_token, { exp_leeway: leeway, algorithm: 'HS256' }
  end
end
