FactoryBot.define do
  factory :query do
    association :view, factory: :view
    description { "This is the query description" }
    published { true }
    trait :with_form_container do
      association :container, factory: :container
    end
  end
end
