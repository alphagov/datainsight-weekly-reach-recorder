require_relative "../spec_helper"

require 'sinatra/base'
require "rack/test"

require_relative "../../lib/app"

def create_measurements(start_at, end_at, params={})
  while start_at < end_at
    each_end_at = start_at + 7
    params[:start_at] = start_at
    params[:end_at] = each_end_at
    FactoryGirl.create(:model, params)

    start_at += 7
  end
end
