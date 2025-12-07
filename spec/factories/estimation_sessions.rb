FactoryBot.define do
  factory :estimation_session do
    association :project
    association :estimation_option
    association :facilitator, factory: :user
    association :current_effort, factory: :effort
    status { :active }
  end
end
