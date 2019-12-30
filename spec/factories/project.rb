FactoryBot.define do
  factory :project do
    published { true }
    association :company, factory: :company
  end
end
