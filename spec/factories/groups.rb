# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    purpose "Testing differents groups"
  end
end
