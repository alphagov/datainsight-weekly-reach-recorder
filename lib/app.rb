require 'sinatra'
require 'json'
require 'datainsight_logging'

require_relative 'model'
require_relative 'datamapper_config'

helpers Datainsight::Logging::Helpers

configure do
  enable :logging
  unless test?
    Datainsight::Logging.configure(:type => :exposer)
    DataMapperConfig.configure
  end
end

def convert_to_correct_format(weekly_visits)
  weekly_visits.map { |each| {"date" => each.week_ending, "value" => each.value} }
end

def create_json_response(metric)
  {
    :govuk => convert_to_correct_format(WeeklyReach::Model.govuk(metric)),
    :directgov => convert_to_correct_format(WeeklyReach::Model.directgov(metric)),
    :businesslink => convert_to_correct_format(WeeklyReach::Model.businesslink(metric)),

    :highlight_spikes => WeeklyReach::Model.highlight_spikes(metric),
    :highlight_troughs => WeeklyReach::Model.highlight_troughs(metric)
  }.to_json
end

get '/weekly-visits' do
  content_type :json
  create_json_response(:visits)
end

get '/weekly-visitors' do
  content_type :json
  create_json_response(:visitors)
end

error do
  logger.error env['sinatra.error']
end
