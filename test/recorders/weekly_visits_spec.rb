require 'bundler/setup'
Bundler.require

require_relative "../lib/datamodel"
require_relative "../lib/recorders/weekly_visits_recorder"
require_relative "../lib/weekly_visits_model"
DataMapperConfig.configure_test

describe "WeeklyVisitsRecorder" do

  after :each do
    WeeklyVisits.destroy
  end

  it "should store weekly visits when processing drive message" do
    message = {
        :envelope => {
            :collected_at => DateTime.now,
            :collector => "visits"
        },
        :payload => {
            :value => 700,
            :week_starting => Date.parse("28/3/2011"),
            :site => "directgov"
        }
    }

    Recorders::WeeklyVisitsRecorder.process_drive_message(message)

    WeeklyVisits.all.should_not be_empty
    end

  it "should store hourly data when processing analytics message" do
    message = {
        :envelope => {
            :collected_at => DateTime.now,
            :collector => "visits"
        },
        :payload => {
            :value => 700,
            :start_at => DateTime.parse("03/08/2012 11:00:00"),
            :end_at => DateTime.parse("03/08/2012 12:00:00"),
            :site => "govuk"
        }
    }

    Recorders::WeeklyVisitsRecorder.process_analytics_message(message)

    WeeklyVisits.all.should_not be_empty
    end

  it "should store hourly data when processing analytics message for 23:00 - 00:00 hour on Sunday" do
    message = {
        :envelope => {
            :collected_at => DateTime.now,
            :collector => "visits"
        },
        :payload => {
            :value => 700,
            :start_at => DateTime.parse("05/08/2012 23:00:00"),
            :end_at => DateTime.parse("05/08/2012 00:00:00"),
            :site => "govuk"
        }
    }

    Recorders::WeeklyVisitsRecorder.process_analytics_message(message)

    WeeklyVisits.all.should_not be_empty
    WeeklyVisits.first.week_starting.should == Date.parse("30/07/2012")
  end

  it "should add hourly data to an existing week" do
    WeeklyVisits.create(
        :value => 100,
        :week_starting => Date.parse("30/07/2012"),
        :site => "govuk"
      )

    message = {
        :envelope => {
            :collected_at => DateTime.now,
            :collector => "visits"
        },
        :payload => {
            :value => 700,
            :start_at => DateTime.parse("03/08/2012 11:00:00"),
            :end_at => DateTime.parse("03/08/2012 12:00:00"),
            :site => "govuk"
        }
    }

    Recorders::WeeklyVisitsRecorder.process_analytics_message(message)

    WeeklyVisits.all.length.should == 1
  end
end