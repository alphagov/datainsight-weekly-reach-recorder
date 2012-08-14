require_relative "../../lib/datamapper_config"
require_relative "../../lib/model"

FactoryGirl.define do
  factory :model, class: WeeklyReach::Model do
    start_at DateTime.parse("2012-08-06 10:00:00")
    end_at DateTime.parse("2012-08-06 11:00:00")
    value 500
    metric "visits"
    site "govuk"
    collected_at DateTime.now
  end
end