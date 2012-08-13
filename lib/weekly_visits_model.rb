require "bundler"
Bundler.require

class WeeklyVisits
  include DataMapper::Resource
  property :id, Serial
  property :value, Integer
  property :start_at, Date
  property :end_at, Date
  property :collected_at, DateTime
  property :site, String

  def week_ending
    end_at
  end

  def self.last_six_months_data(site)
    past_six_months = (Date.today - 7) << 6
    WeeklyVisits.all(:start_at.gte => past_six_months, :site => site)
  end

  def self.govuk
    last_six_months_data("govuk")
  end

  def self.directgov
    last_six_months_data("directgov")
  end

  def self.businesslink
    last_six_months_data("businesslink")
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

  def self.highlight_spikes
    data = govuk.map { |each| each["value"] }
    (data.max - self.median(data)).abs / self.median(data).to_f > (HIGHLIGHT_SPIKES_THRESHOLD)
  end

  def self.highlight_troughs
    data = govuk.map { |each| each["value"] }
    highlight_troughs_threshold = 1 - 1 / (1 + HIGHLIGHT_SPIKES_THRESHOLD)
    (data.min - self.median(data)).abs / self.median(data).to_f > highlight_troughs_threshold
  end

end
