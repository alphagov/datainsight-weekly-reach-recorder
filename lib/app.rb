require "bundler"
Bundler.require

require 'sinatra'
require 'json'

require_relative 'weekly_visits_model'



get '/weekly-visits' do
  content_type :json

  weekly_visits = WeeklyVisits.new

  response = {}
  response[:govuk] = WeeklyVisits.govuk
  response[:directgov] = WeeklyVisits.directgov
  response[:businesslink] = WeeklyVisits.businesslink

  response[:highlight_spikes] = WeeklyVisits.highlight_spikes
  response[:highlight_troughs] = WeeklyVisits.highlight_troughs
  response.to_json
end

