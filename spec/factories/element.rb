FactoryBot.define do
  factory :element do
    association :elementable, factory: :numeric_input
    association :container, factory: :container
  end
end