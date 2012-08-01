require "bundler"
Bundler.require

require 'sinatra'

require_relative 'weekly_visits'

get '/weekly_visits' do
  content_type :json
  {:content => WeeklyVisits.new.content}.to_json
end
