require_relative "test_helper"
require_relative "../lib/recorders/weekly_visits_recorder"
require_relative "../lib/weekly_visits_model"

describe "WeeklyVisitsRecorder" do

  after :each do
    WeeklyVisits.destroy
  end

  it "should return data for the past six months" do
    WeeklyVisits.create(
        :value => 100,
        :week_starting => Date.today,
        :site => "govuk"
    )

    WeeklyVisits.create(
        :value => 400,
        :week_starting => Date.today<<12,
        :site => "govuk"
    )

    WeeklyVisits.create(
        :value => 200,
        :week_starting => Date.today<<6,
        :site => "govuk"
    )

    WeeklyVisits.govuk.length.should == 2
    WeeklyVisits.govuk.map(&:value).reduce(&:+).should == 300
  end

  it "should return data for the past six months for govuk only" do
    WeeklyVisits.create(
        :value => 100,
        :week_starting => Date.today,
        :site => "businesslink"
    )

    WeeklyVisits.create(
        :value => 400,
        :week_starting => Date.today<<12,
        :site => "govuk"
    )

    WeeklyVisits.create(
        :value => 200,
        :week_starting => Date.today<<6,
        :site => "govuk"
    )

    WeeklyVisits.govuk.length.should == 1
    WeeklyVisits.govuk.map(&:value).reduce(&:+).should == 200
  end

end