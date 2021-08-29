FactoryBot.define do
  factory :text_input do
    multiline { false }
    regex { nil }
    required { false }

    trait :singleline do
      multiline { false }
    end
    trait :multiline do
      multiline { true }
    end
    trait :one_or_more_digits do
      regex { "^[0-9]+$" }
    end

    trait :required do
      required { true }
    end
  end
end
