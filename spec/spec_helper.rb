require 'rspec'
require 'bundler/setup'
Bundler.require

ENV['RACK_ENV'] = 'test'
require 'factory_girl'
require 'datainsight_recorder/datamapper_config'
require_relative '../lib/model'

require 'timecop'

FactoryGirl.find_definitions
Datainsight::Logging.configure(:env => :test)
DataInsight::Recorder::DataMapperConfig.configure(:test)