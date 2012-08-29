source "https://rubygems.org"

gem "data_mapper", "1.2.0"
gem "dm-mysql-adapter", "1.2.0"
gem "rake"
gem "datainsight_logging", :git => "git@github.com:alphagov/datainsight_logging.git"
#gem "datainsight_logging", :path => "../datainsight_logging"

group :exposer do
  gem "sinatra"
  gem "unicorn"
end

group :recorder do
  gem "bunny"
  gem "gli", "1.6.0"
end

group :test do
  gem "dm-sqlite-adapter", "1.2.0"
  gem "rspec"
  gem "rack-test"
  gem "ci_reporter"
  gem "factory_girl"
end
