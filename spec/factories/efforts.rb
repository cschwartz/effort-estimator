FactoryBot.define do
  factory :effort do
    sequence(:title) { |n| "Effort #{n}" }
    project

    trait :with_parent do
      association :parent, factory: :effort
    end
  end
end
