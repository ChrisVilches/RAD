FactoryBot.define do
  factory :user do

    sequence :email do |n|
      "useremail#{n}@domain.com"
    end

    sequence :password do |n|
      "asdasd123123#{n}"
    end
  end
end
