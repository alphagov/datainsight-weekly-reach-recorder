require 'json'
require 'bundler/setup'
Bundler.require(:default, :exposer)

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

def create_json_response(metric)
{
    :response_info => {:status => "ok"},
    :id => "/format-success",
    :web_url => "",
    :details => {
      :source => ["Google Analytics", "Celebrus", "Omniture"],
      :highlight_spikes => WeeklyReach::Model.highlight_spikes(metric),
      :highlight_troughs => WeeklyReach::Model.highlight_troughs(metric),
      :data => WeeklyReach::Model.last_six_months_data(metric)
    },
    :updated_at => WeeklyReach::Model.updated_at(metric)
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
