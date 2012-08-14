require "bundler"
Bundler.require

module WeeklyReach
  class Model
    include DataMapper::Resource
    property :id, Serial
    property :metric, String
    property :value, Integer
    property :start_at, Date
    property :end_at, Date
    property :collected_at, DateTime
    property :site, String

    def week_ending
      end_at
    end

    def self.last_six_months_data(site, metric)
      past_six_months = (Date.today - 7) << 6
      Model.all(
        :metric => metric,
        :start_at.gte => past_six_months,
        :site => site,
        :order => [ :start_at.asc ])
    end

    def self.govuk(metric)
      last_six_months_data("govuk", metric)
    end

    def self.directgov(metric)
      last_six_months_data("directgov", metric)
    end

    def self.businesslink(metric)
      last_six_months_data("businesslink", metric)
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

    def self.highlight_spikes(metric)
      data = govuk(metric).map { |each| each["value"] }
      if data.empty?
        false
      else
        (data.max - self.median(data)).abs / self.median(data).to_f > (HIGHLIGHT_SPIKES_THRESHOLD)
      end
    end

    def self.highlight_troughs(metric)
      data = govuk(metric).map { |each| each["value"] }
      if data.empty?
        false
      else
        highlight_troughs_threshold = 1 - 1 / (1 + HIGHLIGHT_SPIKES_THRESHOLD)
        (data.min - self.median(data)).abs / self.median(data).to_f > highlight_troughs_threshold
      end
    end

  end
end