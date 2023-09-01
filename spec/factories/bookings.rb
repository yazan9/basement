FactoryBot.define do
  factory :booking do
    # add other attributes here
    user

    status { :active }
    rate { 35 }
    hours { 2 }
    offset { 3 }

    trait :once do
      frequency { :once }
    end

    trait :once_a_week do
      frequency { :once_a_week }
    end

    trait :twice_a_week do
      frequency { :twice_a_week }
    end

    trait :once_every_two_weeks do
      frequency { :once_every_two_weeks }
    end
  end
end