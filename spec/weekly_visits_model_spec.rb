require_relative "spec_helper"
require_relative "../lib/recorder"
require_relative "../lib/model"

describe "WeeklyVisits" do

  after :each do
    WeeklyReach::Model.destroy
  end

  it "should return data for the past six months" do
    WeeklyReach::Model.create(
        :value => 100,
        :metric => "visits",
        :start_at => Date.today,
        :end_at => Date.today + 6,
        :collected_at => DateTime.now,
        :site => "govuk"
    )

    WeeklyReach::Model.create(
        :value => 400,
        :metric => "visits",
        :start_at => Date.today << 12,
        :end_at => (Date.today << 12) + 6,
        :collected_at => DateTime.now,
        :site => "govuk"
    )

    WeeklyReach::Model.create(
        :value => 200,
        :metric => "visits",
        :start_at => Date.today << 6,
        :end_at => (Date.today << 6) + 6,
        :collected_at => DateTime.now,
        :site => "govuk"
    )

    WeeklyReach::Model.last_six_months_data(:visits).length.should == 2
    WeeklyReach::Model.last_six_months_data(:visits).map { |each| each[:value][:govuk] }.reduce(&:+).should == 300
  end

  it "should return data for the past six months for mixed sites" do
    WeeklyReach::Model.create(
        :value => 100,
        :metric => "visits",
        :start_at => Date.today,
        :end_at => Date.today + 6,
        :collected_at => DateTime.now,
        :site => "businesslink"
    )

    WeeklyReach::Model.create(
        :value => 400,
        :metric => "visits",
        :start_at => Date.today << 12,
        :end_at => (Date.today << 12) + 6,
        :collected_at => DateTime.now,
        :site => "govuk"
    )

    WeeklyReach::Model.create(
        :value => 200,
        :metric => "visits",
        :start_at => Date.today << 6,
        :end_at => (Date.today << 6) + 6,
        :collected_at => DateTime.now,
        :site => "govuk"
    )

    WeeklyReach::Model.last_six_months_data(:visits).length.should == 2
    WeeklyReach::Model.last_six_months_data(:visits).map { |each| each[:value][:govuk] || 0 }.reduce(&:+).should == 200
    WeeklyReach::Model.last_six_months_data(:visits).map { |each| each[:value][:businesslink] || 0 }.reduce(&:+).should == 100
  end

  describe "validates start and end at" do
    it "should be valid data if data is ok" do
      model = FactoryGirl.create(:model, {
          :start_at => Date.parse("2012-08-12"),
          :end_at => Date.parse("2012-08-18"),
      })

      model.should be_valid
    end

    it "should not be valid if there are 6 days between start at and end at" do
      model = FactoryGirl.create(:model, {
          :start_at => Date.parse("2012-08-12"),
          :end_at => Date.parse("2012-08-17"),
      })

      model.should_not be_valid
    end

    it "should not be valid if there are 8 days between start at and end at" do
      model = FactoryGirl.create(:model, {
          :start_at => Date.parse("2012-08-12"),
          :end_at => Date.parse("2012-08-19"),
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
