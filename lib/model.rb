require "data_mapper"
require "datainsight_recorder/base_fields"
require "datainsight_recorder/time_series"

module WeeklyReach
  class Model
    include DataMapper::Resource
    include DataInsight::Recorder::BaseFields
    include DataInsight::Recorder::TimeSeries

    SITES = %w(govuk directgov businesslink)
    METRICS = %w(visits visitors)

    property :metric, String, required: true
    property :site, String, required: true
    property :value, Integer, required: true

    validates_within :site, set: SITES
    validates_within :metric, set: METRICS

    validates_with_method :validate_value
    validates_with_method :validate_time_series_week

    def self.last_six_months_data(metric)
      past_six_months = (Date.today - 7) << 6
      Model.all(
        :metric => metric,
        :start_at.gte => past_six_months,
        :order => [ :start_at.asc ]
      ).group_by {|each| [each[:start_at], each[:end_at]] }.map {|(start_at, end_at), values|
        {
          :start_at => start_at.to_date,
          :end_at => end_at.to_date,
          :value => Hash[values.group_by(&:site).map {|site, value| [site.to_sym, value[0][:value]]}]
        }
      }
    end

    def self.updated_at(metric)
      Model.max(:collected_at, :metric => metric)
    end


    private

    def validate_value
      if value.nil? || value >= 0
        true
      else
        [false, "Value cannot be negative."]
      end
    end

  end
end