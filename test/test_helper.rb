Bundler.require(:default, :test)
require "rspec"

require_relative "../lib/datamapper_config"
require_relative "../lib/weekly_visits_model"
DataMapperConfig.configure_test