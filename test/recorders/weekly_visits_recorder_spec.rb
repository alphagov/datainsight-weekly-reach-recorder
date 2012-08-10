require_relative "../test_helper"
require_relative "../../lib/recorders/weekly_visits_recorder"
require_relative "../../lib/weekly_visits_model"

describe "WeeklyVisitsRecorder" do
  before(:each) do
    @message = {
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
  end

  after :each do
    WeeklyVisits.destroy
  end

  it "should store weekly visits when processing drive message" do
    Recorders::WeeklyVisitsRecorder.process_message(@message)

    WeeklyVisits.all.should_not be_empty
  end

  it "should store weekly data when processing analytics message" do
    @message[:payload][:site] = "govuk"
    Recorders::WeeklyVisitsRecorder.process_message(@message)

    WeeklyVisits.all.should_not be_empty
  end

  it "should update existing measurements" do
    Recorders::WeeklyVisitsRecorder.process_message(@message)
    @message[:payload][:value] = 900
    Recorders::WeeklyVisitsRecorder.process_message(@message)
    WeeklyVisits.all.length.should == 1
    WeeklyVisits.first.value.should == 900
  end
end