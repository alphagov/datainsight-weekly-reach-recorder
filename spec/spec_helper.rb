require 'rspec'
require 'datainsight_logging'

ENV['RACK_ENV'] = 'test'
require 'factory_girl'
require_relative '../lib/datamapper_config'
require_relative '../lib/model'

FactoryGirl.find_definitions
Datainsight::Logging.configure(:env => :test)
DataMapperConfig.configure(:test)