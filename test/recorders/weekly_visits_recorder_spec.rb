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
            :start_at => "2011-03-28T00:00:00",
            :end_at => "2011-04-04T00:00:00",
            :site => "directgov"
        }
    }
    @recorder = Recorders::WeeklyVisitsRecorder.new(nil)
  end

  after :each do
    WeeklyVisits.destroy
  end

  it "should store weekly visits when processing drive message" do
    @recorder.process_message(@message)

    WeeklyVisits.all.should_not be_empty
    item = WeeklyVisits.first
    item.value.should == 700
    item.start_at.should == Date.new(2011, 3, 28)
    item.end_at.should == Date.new(2011, 4, 3)
    item.site.should == "directgov"
  end

  it "should store weekly data when processing analytics message" do
    @message[:payload][:site] = "govuk"
    @recorder.process_message(@message)

    WeeklyVisits.all.should_not be_empty
    item = WeeklyVisits.first
    item.value.should == 700
    item.start_at.should == Date.new(2011, 3, 28)
    item.end_at.should == Date.new(2011, 4, 3)
    item.site.should == "govuk"
  end

  it "should correctly handle end date over month boundaries" do
    @message[:payload][:end_at] = "2011-09-01T00:00:00"
    @recorder.process_message(@message)
    item = WeeklyVisits.first
    item.end_at.should == Date.new(2011, 8, 31)
  end

  it "should update existing measurements" do
    @recorder.process_message(@message)
    @message[:payload][:value] = 900
    @recorder.process_message(@message)
    WeeklyVisits.all.length.should == 1
    WeeklyVisits.first.value.should == 900
  end
end
