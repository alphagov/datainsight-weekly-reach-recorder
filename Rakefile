require 'rubygems'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

RSpec::Core::RakeTask.new do |task|
  task.pattern = 'test/**/*_spec.rb'
  task.rspec_opts = ["--format documentation"]
end