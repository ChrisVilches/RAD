FactoryBot.define do
  factory :project do
    sequence :name do |n|
      "Project ##{n}"
    end
    published { true }
    association :company, factory: :company
  end
end
