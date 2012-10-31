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
    start_at ||= last_sunday_of(DateTime.now << 6)
    end_at ||= last_sunday_of(DateTime.now)
    end_date_of_a_first_week = (DateTime.now << 6) + 7

    create_measurements(start_at, end_at, metric: "visitors", value: 500, site: "govuk")
    create_measurements(start_at, end_at, metric: "visitors", value: 600, site: "directgov")
    create_measurements(start_at, end_at, metric: "visitors", value: 700, site: "businesslink")

    get "/weekly-visitors"
    last_response.should be_ok
    response = JSON.parse(last_response.body, :symbolize_names => true)

    response.should have_key(:id)
    response.should have_key(:web_url)
    response.should have_key(:updated_at)
    response[:response_info][:status].should == "ok"

    data = response[:details][:data]

    govuk = data[:govuk]
    govuk.should have(27).items
    govuk.first[:date].should == last_sunday_of(end_date_of_a_first_week).to_date.strftime
    govuk.first[:value].should == 500

    directgov = data[:directgov]
    directgov.should have(27).items
    directgov.first[:date].should == last_sunday_of(end_date_of_a_first_week).to_date.strftime
    directgov.first[:value].should == 600

    businesslink = data[:businesslink]
    businesslink.should have(27).items
    businesslink.first[:date].should == last_sunday_of(end_date_of_a_first_week).to_date.strftime
    businesslink.first[:value].should == 700

    data[:highlight_spikes].should == false
    data[:highlight_troughs].should == false
  end
end