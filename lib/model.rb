require "bundler"
Bundler.require

module WeeklyReach
  class Model
    include DataMapper::Resource

    SITES = %w(govuk directgov businesslink)
    METRICS = %w(visits visitors)

    property :id, Serial
    property :metric, String, required: true
    property :value, Integer, required: true
    property :start_at, Date, required: true
    property :end_at, Date, required: true
    property :collected_at, DateTime, required: true
    property :site, String, required: true

    validates_within :site, :set => SITES
    validates_within :metric, :set => METRICS
    validates_with_method :validate_value_positive, :if => lambda { |m| not m.value.nil? }
    validates_with_method :validate_week_length, :if => lambda { |m| (not m.start_at.nil?) and (not m.end_at.nil?) }

    def self.last_six_months_data(metric)
      past_six_months = (Date.today - 7) << 6
      Model.all(
        :metric => metric,
        :start_at.gte => past_six_months,
        :order => [ :start_at.asc ]
      ).group_by {|each| [each[:start_at], each[:end_at]] }.map {|(start_at, end_at), values|
        {
          :start_at => start_at,
          :end_at => end_at,
          :value => Hash[values.group_by(&:site).map {|site, value| [site.to_sym, value[0][:value]]}]
        }
      }
    end

    def self.updated_at(metric)
      Model.max(:collected_at, :metric => metric)
    end

    def self.median(data)
      return 0 if data.empty?
      mid, remainder = data.length.divmod(2)
      if remainder == 0
        data.sort[mid-1,2].inject(:+) / 2.0
      else
        data.sort[mid]
      end
    end

    HIGHLIGHT_SPIKES_THRESHOLD = 0.15

    # This controls switching the gradient off if the sites
    # other than govuk have much higher values.
    MIN_PERCENTAGE_OF_GOV_UK_OF_ALL_VALUES_TO_HIGHLIGHT = 0.1
    def self.should_show_gradient?(data, metric)
      max_of_businesslink_and_directgov = last_six_months_data(metric).map {|each|
        [each[:value][:directgov] || 0, each[:value][:businesslink] || 0]
      }.flatten.max
      data.max < (MIN_PERCENTAGE_OF_GOV_UK_OF_ALL_VALUES_TO_HIGHLIGHT * max_of_businesslink_and_directgov)
    end

    def self.highlight_spikes(metric)
      data = last_six_months_data(metric).map { |each| each[:value][:govuk] || 0 }
      if data.empty?
        false
      elsif self.should_show_gradient?(data, metric)
        false
      else
        (data.max - self.median(data)).abs / self.median(data).to_f > (HIGHLIGHT_SPIKES_THRESHOLD)
      end
    end

    def self.highlight_troughs(metric)
      data = last_six_months_data(metric).map { |each| each[:value][:govuk] || 0 }
      if data.empty?
        false
      elsif self.should_show_gradient?(data, metric)
        false
      else
        highlight_troughs_threshold = 1 - 1 / (1 + HIGHLIGHT_SPIKES_THRESHOLD)
        (data.min - self.median(data)).abs / self.median(data).to_f > highlight_troughs_threshold
      end
    end

    private
    def validate_value_positive
      if value >= 0
        true
      else
        [false, "Value cannot be negative."]
      end
    end

    def validate_week_length
      if (self.end_at - self.start_at) == 6
        true
      else
        [false, "The time between start at and end at should be a week."]
      end
    end

  end
end