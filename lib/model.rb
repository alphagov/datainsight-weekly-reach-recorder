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

    def self.update_from_message(message)
      metric = parse_metric(message[:envelope][:_routing_key]).to_sym
      query = {
        :metric => metric,
        :start_at => DateTime.parse(message[:payload][:start_at]),
        :end_at => DateTime.parse(message[:payload][:end_at]),
        :site => message[:payload][:value][:site]
      }
      record = Model.first(query)
      record = Model.new(query) unless record

      record.collected_at = DateTime.parse(message[:envelope][:collected_at])
      record.source = message[:envelope][:collector]
      record.value = message[:payload][:value][metric]
      record.save
      begin
        record.save
      rescue DataMapper::SaveFailureError => e
        begin
          logger.error("SaveFailure: #{e.resource.errors.inspect}")
        rescue NoMethodError
          logger.error("SaveFailure (no detail): #{e}")
        end
        raise
      end
    end

    def self.last_18_months_data(metric)
      past_18_months_data = Model.all(
        :metric => metric,
        :start_at.gte => ((Date.today - 7) << 18),
        :order => [:start_at.asc]
      )
      group_by_start_and_end(past_18_months_data).map {|(start_at, end_at), values|
        {
          :start_at => start_at.to_date,
          :end_at => (end_at-1).to_date,
          :value => Hash[values.group_by(&:site).map {|site, value| [site.to_sym, value[0][:value]]}]
        }
      }
    end

    def self.group_by_start_and_end(iterable)
      iterable.group_by {|each| [each[:start_at], each[:end_at]] }
    end

    def self.updated_at(metric)
      Model.max(:collected_at, :metric => metric)
    end


    private
    def self.parse_metric(routing_key)
      /\.(?<metric>visits|visitors)\.weekly$/.match(routing_key)[:metric] or raise "Invalid metric for key [#{routing_key}] "
    end

    def validate_value
      if value.nil? || value >= 0
        true
      else
        [false, "Value cannot be negative."]
      end
    end

  end
end