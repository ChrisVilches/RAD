FactoryBot.define do
  factory :connection do
    association :project, factory: :project
    db_type { Connection.db_types.keys.sample }
  end
end
