class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_one_attached :profile_image

  has_many :reviews_given, class_name: 'Review', foreign_key: 'user_id'
  has_many :reviews_received, class_name: 'Review', foreign_key: 'reviewee_id'
  has_many :bookings, dependent: :destroy
  has_many :booking_slots, dependent: :destroy

  validate :password_complexity

  enum user_type: {
    client: 0,
    provider: 1
  }

  def password_complexity
    if password.present? and not password.match(/\A(?=.*[0-9]).{6,}\z/)
      errors.add :password, 'must include at least one number and have at least 6 characters'
    end
  end

  def average_rating
    reviews_received.average(:rating).to_f.round(2)
  end

  def ratings_count
    reviews_received.count
  end

  def profile_image_url
    if profile_image.attached?
      public_bucket = ENV.fetch('AWS_BUCKET_PIXIES_NAME_PUBLIC', 'pixies-public')
      "https://#{public_bucket}.s3.amazonaws.com/#{profile_image.blob.key}"
    else
      ''
    end
  end

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

  #called by confirmable module
  def send_devise_notification(notification, *args)
    AccountMailerWorker.perform_async(self.id, 'new_account', *args)
  end
end
