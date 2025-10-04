FactoryBot.define do
  factory :category do
    association :project
    sequence(:title) { |n| "Category #{n}" }
    category_type { :scaled }
  end
end
