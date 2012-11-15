require_relative "../../lib/datamapper_config"
require_relative "../../lib/model"

FactoryGirl.define do
  factory :model, class: WeeklyReach::Model do
    start_at Date.parse("2012-08-06")
    end_at Date.parse("2012-08-12")
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