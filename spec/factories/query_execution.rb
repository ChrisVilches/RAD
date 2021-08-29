FactoryBot.define do
  factory :query_execution do
    query { create(:query) }
    query_history { create(:query_history, query: query) }
    association :user, factory: :user
    association :connection, factory: :connection
    global_params { [] }
    query_params { [] }
  end
end
