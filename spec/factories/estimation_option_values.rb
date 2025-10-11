FactoryBot.define do
  factory :estimation_option_value do
    association :estimation_option
    sequence(:value) { |n| n }
  end
end
