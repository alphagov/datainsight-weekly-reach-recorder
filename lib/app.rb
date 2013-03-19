require 'json'
require 'bundler/setup'
Bundler.require(:default, :exposer)

require "datainsight_recorder/datamapper_config"

require_relative 'model'
require_relative "initializers"

helpers Datainsight::Logging::Helpers

use Airbrake::Rack
enable :raise_errors

configure do
  enable :logging
  unless test?
    Datainsight::Logging.configure(:type => :exposer)
    DataInsight::Recorder::DataMapperConfig.configure
  end
end

TIMESTAMP_FORMAT="%Y-%m-%dT%H:%M:%S"

def create_json_response(metric, id)
{
    :response_info => {:status => "ok"},
    :id => id,
    :web_url => "",
    :details => {
      :source => ["Google Analytics", "Celebrus", "Omniture"],
      :data => WeeklyReach::Model.last_six_months_data(metric)
    },
    :updated_at => WeeklyReach::Model.updated_at(metric).strftime(TIMESTAMP_FORMAT)
  }.to_json
end

get '/weekly-visits' do
  content_type :json
  create_json_response(:visits, request.path_info)
end

get '/weekly-visitors' do
  content_type :json
  create_json_response(:visitors, request.path_info)
end

error do
  logger.error env['sinatra.error']
end
