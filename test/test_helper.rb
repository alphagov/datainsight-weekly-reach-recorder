Bundler.require(:default, :test)
require "rspec"

require_relative "../lib/datamodel"
require_relative "../lib/weekly_visits_model"
DataMapperConfig.configure_test