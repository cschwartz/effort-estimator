FactoryBot.define do
  factory :parameter do
    project
    sequence(:title) { |n| "Parameter #{n}" }
  end
end
