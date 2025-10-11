FactoryBot.define do
  factory :estimation_option do
    sequence(:title) { |n| "Estimation Option #{n}" }
  end
end
