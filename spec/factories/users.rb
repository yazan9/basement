FactoryBot.define do
  factory :user do
    password { "password123" }

    trait :provider do
      user_type { :provider }
    end

    trait :client do
      user_type { :client }
    end
  end
end