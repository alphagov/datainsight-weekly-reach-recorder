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

  it "should calculate the mean and median correctly" do
    even_data = [1,2,3,4,5,6,7,8]
    odd_data = [1,2,3,4,5,6,7,8,9]

    WeeklyVisits.median(even_data).should == 4.5
    WeeklyVisits.median(odd_data).should == 5
  end

end