require_relative "../test_helper"
require_relative "../../lib/recorders/weekly_visits_recorder"
require_relative "../../lib/weekly_visits_model"

describe "WeeklyVisitsRecorder" do

  after :each do
    WeeklyVisits.destroy
  end

  it "should store weekly visits when processing drive message" do
    message = {
        :envelope => {
            :collected_at => DateTime.now.strftime,
            :collector => "visits"
        },
        :payload => {
            :value => 700,
            :week_starting => "28/3/2011",
            :site => "directgov"
        }
    }

    Recorders::WeeklyVisitsRecorder.process_message(message)

    WeeklyVisits.all.should_not be_empty
  end

  it "should store hourly data when processing analytics message" do
    message = {
        :envelope => {
            :collected_at => DateTime.now.strftime,
            :collector => "visits"
        },
        :payload => {
            :value => 700,
            :week_starting => "30/07/2012",
            :site => "govuk"
        }
    }

    Recorders::WeeklyVisitsRecorder.process_message(message)

    WeeklyVisits.all.should_not be_empty
  end
end