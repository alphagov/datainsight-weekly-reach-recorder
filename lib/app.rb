require "bundler"
Bundler.require

require 'sinatra'
require 'json'

require_relative 'weekly_visits_model'

get '/weekly_visits' do
  content_type :json

  weekly_visits = WeeklyVisits.new

  response = {}
  response[:govuk] = weekly_visits.govuk
  response[:directgov] = weekly_visits.directgov
  response[:businesslink] = weekly_visits.businesslink

  response[:highlight_spikes] = weekly_visits.highlight_spikes
  response[:highlight_troughs] = weekly_visits.highlight_troughs
  response.to_json
end
