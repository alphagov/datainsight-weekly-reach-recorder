require_relative "../test_helper"

require 'sinatra/base'
require "rack/test"

require_relative "../../lib/app"

def create_sunday(date_time)
  date_time - date_time.wday
end

def create_measurements(params={})
  params[:start_at] ||= create_sunday((DateTime.now << 6) - 5)
  params[:end_at] ||= (DateTime.now - 5)

  end_at = params[:end_at]
  while params[:start_at] < end_at
    params[:end_at] = params[:start_at] + 7
    FactoryGirl.create(:model, params)

    params[:start_at] += 7
  end
end
