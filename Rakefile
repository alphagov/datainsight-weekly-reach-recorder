require 'rubygems'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
require_relative "lib/datamapper_config"

task :environment do
  DataMapperConfig.configure
end

unless [ENV["RACK_ENV"], ENV["RAILS_ENV"]].include? "production"
  RSpec::Core::RakeTask.new do |task|
    task.pattern = 'spec/**/*_spec.rb'
    task.rspec_opts = ["--format documentation"]
  end
end

namespace :db do
  desc "Run all pending migrations, or up to specified migration"
  task :migrate, [:version] => :load_migrations do |t, args|
    if version = args[:version] || ENV['VERSION']
      migrate_up!(version)
    else
      migrate_up!
    end
  end

  task :load_migrations => :environment do
    require 'dm-migrations/migration_runner'
    FileList['db/migrate/*.rb'].each do |migration|
      load migration
    end
  end
end
