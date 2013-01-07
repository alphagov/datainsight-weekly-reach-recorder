require_relative "spec_helper"
require_relative "../lib/recorder"
require_relative "../lib/model"

describe "WeeklyVisits" do

  after :each do
    WeeklyReach::Model.destroy
  end

  describe "update from message" do
    before(:each) do
      @message = {
          :envelope => {
              :collected_at => "2012-12-12T00:00:00",
              :collector    => "Google Analytics",
              :_routing_key => "google_analytics.visits.weekly"
          },
          :payload => {
              :start_at => "2011-03-28T00:00:00",
              :end_at => "2011-04-04T00:00:00",
              :value => {
                :visits => 700,
                :site => "directgov"
              }
          }
      }
    end

    it "should insert a new record" do
      WeeklyReach::Model.update_from_message(@message)

      records = WeeklyReach::Model.all

      records.should have(1).item

      records.first.collected_at.should == DateTime.new(2012, 12, 12)
      records.first.source.should == "Google Analytics"
      records.first.start_at.should == DateTime.new(2011, 3, 28)
      records.first.end_at.should == DateTime.new(2011, 4, 4)
      records.first.site.should == "directgov"
      records.first.value.should == 700
    end

    it "should update an existing record" do
      WeeklyReach::Model.update_from_message(@message)
      @message[:payload][:value][:visits] = 800
      WeeklyReach::Model.update_from_message(@message)

      records = WeeklyReach::Model.all

      records.should have(1).item

      records.first.collected_at.should == DateTime.new(2012, 12, 12)
      records.first.source.should == "Google Analytics"
      records.first.start_at.should == DateTime.new(2011, 3, 28)
      records.first.end_at.should == DateTime.new(2011, 4, 4)
      records.first.site.should == "directgov"
      records.first.value.should == 800
    end
  end

  describe "last_six_months_data" do

    it "should return data for the past six months" do
      WeeklyReach::Model.create(
          :value => 100,
          :metric => "visits",
          :start_at => DateTime.new(2012, 12, 23), # Sunday
          :end_at => DateTime.new(2012, 12, 30), # Sunday + 7 days
          :collected_at => DateTime.now,
          :site => "govuk",
          :source => "Google Analytics"
      )

      WeeklyReach::Model.create(
          :value => 400,
          :metric => "visits",
          :start_at => DateTime.new(2012, 1, 22), # Sunday 12 months ago
          :end_at => DateTime.new(2012, 1, 29), # (Sunday 12 months ago) + 7 days
          :collected_at => DateTime.now,
          :site => "govuk",
          :source => "Google Analytics"
      )

      WeeklyReach::Model.create(
          :value => 200,
          :metric => "visits",
          :start_at => DateTime.new(2012, 7, 1), # Sunday 6 months ago
          :end_at => DateTime.new(2012, 7, 8), # Sunday 6 months ago + 7 days
          :collected_at => DateTime.now,
          :site => "govuk",
          :source => "Google Analytics"
      )

      Timecop.travel(DateTime.new(2013, 1, 5)) do
        data = WeeklyReach::Model.last_six_months_data(:visits)
        data.length.should == 2
        data.first[:start_at].should == Date.new(2012, 7, 1)
        data.first[:end_at].should == Date.new(2012, 7, 7)
        data.first[:value][:govuk].should == 200
        data.last[:start_at].should == Date.new(2012, 12, 23)
        data.last[:end_at].should == Date.new(2012, 12, 29)
        data.last[:value][:govuk].should == 100
      end
    end

    it "should return data for the past six months for mixed sites" do
      WeeklyReach::Model.create(
          :value => 100,
          :metric => "visits",
          :start_at => DateTime.new(2012, 12, 24), # Monday
          :end_at => DateTime.new(2012, 12, 31), # Monday + 7 days
          :collected_at => DateTime.now,
          :site => "businesslink",
          :source => "Google Analytics"
      )

      WeeklyReach::Model.create(
          :value => 400,
          :metric => "visits",
          :start_at => DateTime.new(2012, 1, 22), # Sunday 12 months ago
          :end_at => DateTime.new(2012, 1, 29), # (Sunday 12 months ago) + 7 days
          :collected_at => DateTime.now,
          :site => "govuk",
          :source => "Google Analytics"
      )

      WeeklyReach::Model.create(
          :value => 200,
          :metric => "visits",
          :start_at => DateTime.new(2012, 7, 1), # Sunday 6 months ago
          :end_at => DateTime.new(2012, 7, 8), # Sunday 6 months ago + 7 days
          :collected_at => DateTime.now,
          :site => "govuk",
          :source => "Google Analytics"
      )

      Timecop.travel(DateTime.new(2013, 1, 5)) do      
        data = WeeklyReach::Model.last_six_months_data(:visits)
        data.length.should == 2
        data.first[:value][:govuk].should == 200
        data.last[:value][:businesslink].should == 100
      end
    end
  end

  describe "validates start and end at" do
    it "should be valid data if data is ok" do
      model = FactoryGirl.create(:model, {
          :start_at => DateTime.parse("2012-08-12T00:00:00"),
          :end_at => DateTime.parse("2012-08-19T00:00:00"),
      })

      model.should be_valid
    end

    it "should not be valid if there are 6 days between start at and end at" do
      model = FactoryGirl.create(:model, {
          :start_at => DateTime.parse("2012-08-12T00:00:00"),
          :end_at => DateTime.parse("2012-08-18T00:00:00"),
      })

      model.should_not be_valid
    end

    it "should not be valid if there are 8 days between start at and end at" do
      model = FactoryGirl.create(:model, {
          :start_at => DateTime.parse("2012-08-12T00:00:00"),
          :end_at => DateTime.parse("2012-08-20T00:00:00"),
      })

      model.should_not be_valid
    end
  end

  describe "field validation" do
    it "should be invalid if value is null" do
      FactoryGirl.build(:model, :value => nil).should_not be_valid
    end

    it "should be value if the value is positive" do
      FactoryGirl.build(:model, :value => 1).should be_valid
    end

    it "should be invalid if value is negative" do
      FactoryGirl.build(:model, :value => -1).should_not be_valid
    end

    it "should be valid if value is zero" do
      FactoryGirl.build(:model, :value => 0).should be_valid
    end

    it "should have a non-null start_at" do
      FactoryGirl.build(:model, :start_at => nil).should_not be_valid
    end

    it "should have a non-null end_at" do
      FactoryGirl.build(:model, :end_at => nil).should_not be_valid
    end

    it "should have a non-null collected_at" do
      FactoryGirl.build(:model, :collected_at => nil).should_not be_valid
    end

    it "should have a non-null site" do
      FactoryGirl.build(:model, :site => nil).should_not be_valid
    end

    describe "should have a site equal to one of govuk, directgov or businesslink" do
      it "should allow govuk" do
        FactoryGirl.build(:model, :site => "govuk").should be_valid
      end

      it "should allow directgov" do
        FactoryGirl.build(:model, :site => "directgov").should be_valid
      end

      it "should allow businesslink" do
        FactoryGirl.build(:model, :site => "businesslink").should be_valid
      end

      it "should fail with an invalid site" do
        FactoryGirl.build(:model, :site => "invalid").should_not be_valid
      end
    end

    it "should have a non-null metric" do
      FactoryGirl.build(:model, :metric => nil).should_not be_valid
    end

    describe "should have a metric equal to one of visits or visitors" do
      it "should allow visits" do
        FactoryGirl.build(:model, :metric => "visits").should be_valid
      end

      it "should allow visitors" do
        FactoryGirl.build(:model, :metric => "visitors").should be_valid
      end

      it "should not allow invalid" do
        FactoryGirl.build(:model, :metric => "invalid").should_not be_valid
      end
    end
  end

end
