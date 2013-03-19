require_relative "spec_helper"

describe "weekly-visitors" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    Timecop.freeze(Time.utc(2012, 9, 11, 18, 0, 0))
  end

  after(:each) do
    WeeklyReach::Model.destroy!
    Timecop.return
  end

  def last_sunday_of(date_time)
    date_time - (date_time.wday == 0 ? 7 : date_time.wday)
  end

  it "should return JSON data for weekly visitors" do
    start_at = last_sunday_of(Date.today << 6).to_datetime
    end_at = last_sunday_of(Date.today).to_datetime
    end_date_of_a_first_week = (Date.today << 6).to_datetime + 7

    create_measurements(start_at, end_at, metric: "visitors", value: 500, site: "govuk")
    create_measurements(start_at, end_at, metric: "visitors", value: 600, site: "directgov")
    create_measurements(start_at, end_at, metric: "visitors", value: 700, site: "businesslink")

    get "/weekly-visitors"
    last_response.should be_ok
    response = JSON.parse(last_response.body, :symbolize_names => true)

    response.should have_key(:id)
    response.should have_key(:web_url)
    response.should have_key(:updated_at)
    response[:updated_at].should =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/
    response[:response_info][:status].should == "ok"

    data = response[:details][:data]

    data.should have(27).items
    data.first[:start_at].should == start_at.to_date.strftime
    data.first[:end_at].should == (start_at + 6).to_date.strftime
    data.first[:value][:govuk].should == 500
    data.first[:value][:directgov].should == 600
    data.first[:value][:businesslink].should == 700
  end
end