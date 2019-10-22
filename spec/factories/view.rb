FactoryBot.define do
  factory :view do
    association :project, factory: :project

    trait :with_form_container do
      association :main_form_container, factory: :container
    end
  end
end
