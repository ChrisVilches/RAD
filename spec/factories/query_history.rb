FactoryBot.define do
  factory :query_history do
    association :query, factory: :query
  end
end
