FactoryBot.define do
  factory :option_input do
    component_type { OptionInput::component_types[:pulldown] }
    options { [{ label: "my option", value: 1 }] }
    required { false }

    trait :pulldown do
      component_type { OptionInput::component_types[:pulldown] }
    end

    trait :radio do
      component_type { OptionInput::component_types[:radio] }
    end

    trait :checkbox do
      component_type { OptionInput::component_types[:checkbox] }
    end

    trait :colors do
      options {
        [
          { label: "Black", value: "000000" },
          { label: "Red", value: "ff0000" },
          { label: "White", value: "ffffff" },
          { label: "Grey", value: "555555" }
        ]
      }
    end

    trait :device_types do
      options {
        [
          { label: "Smartphone", value: 1 },
          { label: "Desktop PC", value: 2 },
          { label: "Tablet", value: 3 },
          { label: "Radio", value: 4 }
        ]
      }
    end

    trait :numbers do
      options {
        [
          { label: "Pi", value: 3.14159 },
          { label: "Euler", value: 2.71828 }
        ]
      }
    end

  end
end
