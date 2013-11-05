require_relative "../spec_helper"
require_relative "../../lib/recorder"
require_relative "../../lib/model"

describe "WeeklyVisitsRecorder" do
  before(:each) do
    @message = {
        :envelope => {
            :collected_at => DateTime.now.strftime,
            :collector    => "Google Analytics",
            :_routing_key => "google_analytics.visits.weekly"
        },
        :payload => {
            :start_at => "2011-03-28T00:00:00+01:00",
            :end_at => "2011-04-04T00:00:00+01:00",
            :value => {
              :visits => 700,
              :site => "directgov"
            }
        }
    }
    @recorder = WeeklyReach::Recorder.new
  end

  after :each do
    WeeklyReach::Model.destroy
  end

  it "should store weekly visits when processing drive message" do
    @recorder.update_message(@message)

    WeeklyReach::Model.all.should_not be_empty
    item = WeeklyReach::Model.first
    item.metric.should == "visits"
    item.value.should == 700
    item.start_at.should == DateTime.parse("2011-03-28T00:00:00+01:00")
    item.end_at.should == DateTime.parse("2011-04-04T00:00:00+01:00")
    item.site.should == "directgov"
  end

  it "should store weekly data when processing analytics message" do
    @message[:payload][:value][:site] = "govuk"
    @recorder.update_message(@message)

    WeeklyReach::Model.all.should_not be_empty
    item = WeeklyReach::Model.first
    item.metric.should == "visits"
    item.value.should == 700
    item.start_at.should == DateTime.parse("2011-03-28T00:00:00+01:00")
    item.end_at.should == DateTime.parse("2011-04-04T00:00:00+01:00")
    item.site.should == "govuk"
  end

  it "should correctly handle end date over month boundaries" do
    @message[:payload][:start_at] = "2011-08-25T00:00:00"
    @message[:payload][:end_at] = "2011-09-01T00:00:00"
    @recorder.update_message(@message)
    item = WeeklyReach::Model.first
    item.end_at.should == DateTime.new(2011, 9, 1)
  end

  it "should store visitors metric" do
    @message[:envelope][:_routing_key] = "google_analytics.visitors.weekly"
    @message[:payload][:value][:visitors] = @message[:payload][:value].delete(:visits)
    @recorder.update_message(@message)
    item = WeeklyReach::Model.first
    item.metric.should == "visitors"
  end

  it "should raise an error if an invalid metric is parsed" do
    @message[:envelope][:_routing_key] = "google_analytics.invalid.weekly"
    lambda do
      @recorder.update_message(@message)
    end.should raise_error
  end

  it "should raise an error with invalid week on insert" do
    @message[:payload][:start_at] = "2011-03-29T00:00:00" #to short week
    lambda do
      @recorder.update_message(@message)
    end.should raise_error
  end

  it "should update existing measurements" do
    @recorder.update_message(@message)
    @message[:payload][:value][:visits] = 900
    @recorder.update_message(@message)
    WeeklyReach::Model.all.length.should == 1
    WeeklyReach::Model.first.value.should == 900
  end

  describe "validation" do
    it "should fail if value is not present" do
      @message[:payload].delete(:value)

      lambda do
        @recorder.update_message(@message)
      end.should raise_error
    end

    it "should fail if value is not nil and cannot be parsed as a integer" do
      @message[:payload][:value] = "invalid"

      lambda do
        @recorder.update_message(@message)
      end.should raise_error
    end

    it "should not allow nil as a value" do
      @message[:payload][:value][:visits] = nil

      lambda do
        @recorder.update_message(@message)
      end.should raise_error
    end

  end
end
