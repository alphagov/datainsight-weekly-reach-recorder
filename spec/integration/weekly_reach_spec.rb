require_relative "spec_helper"

describe "weekly-visitors" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  after(:each) do
    WeeklyReach::Model.destroy!
  end

  it "should return JSON data for weekly visitors" do
    create_measurements(metric: "visitors", value: 500, site: "govuk")
    create_measurements(metric: "visitors", value: 600, site: "directgov")
    create_measurements(metric: "visitors", value: 700, site: "businesslink")

    get "/weekly-visitors"
    last_response.should be_ok
    response = JSON.parse(last_response.body, :symbolize_names => true)

    govuk = response[:govuk]
    govuk.should have(26).items
    govuk.first[:date].should == create_sunday((DateTime.now << 6)+7).to_date.strftime
    govuk.first[:value].should == 500

    dgov = response[:directgov]
    dgov.should have(26).items
    dgov.first[:date].should == create_sunday((DateTime.now << 6)+7).to_date.strftime
    dgov.first[:value].should == 600

    dlink = response[:businesslink]
    dlink.should have(26).items
    dlink.first[:date].should == create_sunday((DateTime.now << 6)+7).to_date.strftime
    dlink.first[:value].should == 700

    response[:highlight_spikes].should == false
    response[:highlight_troughs].should == false
  end
end