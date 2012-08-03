require "bundler"
Bundler.require

class WeeklyVisits
  include DataMapper::Resource
  property :id, Serial
  property :value, Integer
  property :week_starting, Date
  property :collected_at, DateTime
  property :site, String

  def self.last_six_months_data(site)
    past_six_months = Date.today >> 6
    WeeklyVisits.find(:week_starting.gte => past_six_months, :site => site)
  end

  def self.govuk
    last_six_months_data("govuk")
  end

  def directgov
    last_six_months_data("directgov")
  end

  def businesslink
    last_six_months_data("businesslink")
  end

  def highlight_spikes
    true
  end

  def highlight_troughs
    true
  end

end