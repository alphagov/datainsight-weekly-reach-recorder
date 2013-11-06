require_relative "../spec_helper"

require 'sinatra/base'
require "rack/test"
require "tzinfo"

require_relative "../../lib/app"

def localise(date_time)
  # Convert a DateTime to the same time but in the Europe/London timezone
  # ie. 2012-08-08T00:00:00+00:00 -> 2012-08-08T00:00:00+01:00
  tz = TZInfo::Timezone.get("Europe/London")
  if tz.period_for_utc(date_time).utc_total_offset_rational > 0
    date_time = date_time.new_offset(tz.period_for_utc(date_time).utc_total_offset_rational) - Rational(1, 24)
  end
  date_time
end

def create_measurements(start_at, end_at, params={})
  while start_at < end_at
    each_end_at = start_at + 7
    params[:start_at] = localise(start_at)
    params[:end_at] = localise(each_end_at)
    FactoryGirl.create(:model, params)

    start_at += 7
  end
end
