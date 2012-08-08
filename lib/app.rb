require "bundler"
Bundler.require

require 'sinatra'
require 'json'

require_relative 'weekly_visits_model'
require_relative 'datamapper_config'

configure :development do
  DataMapperConfig.configure_development
end

configure :test do
  DataMapperConfig.configure_test
end

configure :production do
  DataMapperConfig.configure_production
end

def extract_necessary_fields(weekly_visits)
  weekly_visits.map { |each| {"date" => each.week_starting, "value" => each.value} }
end

get '/weekly-visits' do
  content_type :json
  {
      :govuk => extract_necessary_fields(WeeklyVisits.govuk),
      :directgov => extract_necessary_fields(WeeklyVisits.directgov),
      :businesslink => extract_necessary_fields(WeeklyVisits.businesslink),

      :highlight_spikes => WeeklyVisits.highlight_spikes,
      :highlight_troughs => WeeklyVisits.highlight_troughs
  }.to_json
end
