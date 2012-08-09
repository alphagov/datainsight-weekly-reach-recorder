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

def convert_to_correct_format(weekly_visits)
  weekly_visits.map { |each| {"date" => each.week_ending, "value" => each.value} }
end

get '/weekly-visits' do
  content_type :json
  {
      :govuk => convert_to_correct_format(WeeklyVisits.govuk),
      :directgov => convert_to_correct_format(WeeklyVisits.directgov),
      :businesslink => convert_to_correct_format(WeeklyVisits.businesslink),

      :highlight_spikes => WeeklyVisits.highlight_spikes,
      :highlight_troughs => WeeklyVisits.highlight_troughs
  }.to_json
end
