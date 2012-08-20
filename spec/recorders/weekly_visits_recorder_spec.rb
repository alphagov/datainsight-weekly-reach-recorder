require_relative "../spec_helper"
require_relative "../../lib/recorder"
require_relative "../../lib/model"

describe "WeeklyVisitsRecorder" do
  before(:each) do
    @message = {
        :envelope => {
            :collected_at => DateTime.now.strftime,
            :collector => "visits",
            :_routing_key => "google_analytics.visits.weekly"
        },
        :payload => {
            :value => 700,
            :start_at => "2011-03-28T00:00:00",
            :end_at => "2011-04-04T00:00:00",
            :site => "directgov"
        }
    }
    @recorder = WeeklyReach::Recorder.new(nil)
  end

  after :each do
    WeeklyReach::Model.destroy
  end

  it "should store weekly visits when processing drive message" do
    @recorder.process_message(@message)

    WeeklyReach::Model.all.should_not be_empty
    item = WeeklyReach::Model.first
    item.metric.should == "visits"
    item.value.should == 700
    item.start_at.should == Date.new(2011, 3, 28)
    item.end_at.should == Date.new(2011, 4, 3)
    item.site.should == "directgov"
  end

  it "should delete the record when processing a nil drive message" do
    FactoryGirl.create(:model,
        site: "directgov",
        metric: "visits",
        start_at: DateTime.parse("2011-03-28T00:00:00"),
        end_at: DateTime.parse("2011-04-03T00:00:00"),
        value: 700
    )
    @message[:payload][:value] = nil
    @recorder.process_message(@message)

    WeeklyReach::Model.all.should be_empty
  end

  it "should store weekly data when processing analytics message" do
    @message[:payload][:site] = "govuk"
    @recorder.process_message(@message)

    WeeklyReach::Model.all.should_not be_empty
    item = WeeklyReach::Model.first
    item.metric.should == "visits"
    item.value.should == 700
    item.start_at.should == Date.new(2011, 3, 28)
    item.end_at.should == Date.new(2011, 4, 3)
    item.site.should == "govuk"
  end

  it "should correctly handle end date over month boundaries" do
    @message[:payload][:start_at] = "2011-08-25T00:00:00"
    @message[:payload][:end_at] = "2011-09-01T00:00:00"
    @recorder.process_message(@message)
    item = WeeklyReach::Model.first
    item.end_at.should == Date.new(2011, 8, 31)
  end

  it "should store visitors metric" do
    @message[:envelope][:_routing_key] = "google_analytics.visitors.weekly"
    @recorder.process_message(@message)
    item = WeeklyReach::Model.first
    item.metric.should == "visitors"
  end

  it "should raise an error if an invalid metric is parsed" do
    @message[:envelope][:_routing_key] = "google_analytics.invalid.weekly"
    lambda do
      @recorder.process_message(@message)
    end.should raise_error
  end

  it "should raise an error with invalid week on insert" do
    @message[:payload][:start_at] = "2011-03-29T00:00:00" #to short week
    lambda do
      @recorder.process_message(@message)
    end.should raise_error
  end

  it "should update existing measurements" do
    @recorder.process_message(@message)
    @message[:payload][:value] = 900
    @recorder.process_message(@message)
    WeeklyReach::Model.all.length.should == 1
    WeeklyReach::Model.first.value.should == 900
  end

  describe "validation" do
    it "should fail if value is not present" do
      @message[:payload].delete(:value)

      lambda do
        @recorder.process_message(@message)
      end.should raise_error
    end

    it "should fail if value is not nil and cannot be parsed as a integer" do
      @message[:payload][:value] = "invalid"

      lambda do
        @recorder.process_message(@message)
      end.should raise_error
    end

    it "should allow nil as a value" do
      @message[:payload][:value] = nil

      lambda do
        @recorder.process_message(@message)
      end.should_not raise_error
    end

  end
end
