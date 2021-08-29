FactoryBot.define do
  factory :query do
    association :view, factory: :view
    description { 'This is the query description' }
    published { true }
    name { 'Query name' }
    trait :with_form_container do
      association :container, factory: :container
    end
  end
end
