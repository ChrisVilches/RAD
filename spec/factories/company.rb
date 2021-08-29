FactoryBot.define do
  factory :company do
    name { "Company name 株式会社" }

    sequence :url do |n|
      "company-name-kk-#{n}"
    end
  end
end
