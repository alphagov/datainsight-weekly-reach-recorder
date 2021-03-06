FactoryGirl.define do
  factory :model, class: WeeklyReach::Model do
    start_at DateTime.parse("2012-08-06T00:00:00")
    end_at DateTime.parse("2012-08-13T00:00:00")
    value 500
    metric "visits"
    site "govuk"
    collected_at DateTime.now
    source "Google Analytics"
  end

  factory :visits_model, parent: :model do
  end

  factory :visitors_model, parent: :model do
    metric "visitors"
  end
end