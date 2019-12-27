FactoryBot.define do
  factory :query do
    association :view, factory: :view

    trait :with_form_container do
      association :container, factory: :container
    end
  end
end
