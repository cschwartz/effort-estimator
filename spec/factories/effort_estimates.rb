FactoryBot.define do
  factory :effort_estimate do
    association :effort
    association :estimation_session
    association :category
    parameter { nil }
    estimation_option_value { nil }
    status { :pending }

    trait :parameter_selection do
      status { :parameter_selection }
      category { association :category, category_type: :scaled }
    end

    trait :voting do
      status { :voting }
      parameter { association :parameter }
    end

    trait :revealed do
      status { :revealed }
      parameter { association :parameter }
    end

    trait :finalized do
      status { :finalized }
      parameter { association :parameter }
      estimation_option_value { association :estimation_option_value }
    end
  end
end
