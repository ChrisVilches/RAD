FactoryBot.define do
  factory :element do
    association :elementable, factory: :numeric_input
    association :container, factory: :container
    label { "dummy label" }
    position { 0 }

    sequence :variable_name do |n|
      "dummy_element-#{n}"
    end
  end
end
