FactoryBot.define do
  factory :numeric_input do
    number_set { NumericInput::number_sets[:decimal] }

    trait :decimal do
      number_set { NumericInput::number_sets[:decimal] }
    end
    trait :integer do
      number_set { NumericInput::number_sets[:integer] }
    end
    trait :binary do
      number_set { NumericInput::number_sets[:binary] }
    end
  end
end
