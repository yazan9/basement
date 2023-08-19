class Review < ApplicationRecord
  belongs_to :user       # The user who gave the review
  belongs_to :reviewee, class_name: 'User'  # The user for whom the review was written
end
