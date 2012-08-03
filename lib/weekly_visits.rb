require "bundler"
Bundler.require

class Maker
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def make(&code)
    (@start_date..@end_date).step(7).each_with_index.map do |date, i|
      {:date => date, :value => code.call(i, date)}
    end
  end
end

start_date = Date.today.prev_month(6)
end_date   = Date.today
@@maker = Maker.new(start_date, end_date)

class WeeklyVisits
  include DataMapper::Resource
  property :id, Serial
  property :value, Integer
  property :week_starting, Date
  property :collected_at, DateTime
  property :site, String

  def govuk
    @@maker.make { 500 + (rand * 1000).to_i }
  end

  def directgov
    @@maker.make { 2000000 + (rand * 2000000).to_i }
  end

  def businesslink
    @@maker.make { 100000 + (rand * 300000).to_i }
  end

  def highlight_spikes
    true
  end

  def highlight_troughs
    true
  end

end