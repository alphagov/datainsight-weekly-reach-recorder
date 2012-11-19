source "https://rubygems.org"
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem "rake"
gem "datainsight_recorder", "0.0.2"
gem "datainsight_logging"

group :exposer do
  gem "sinatra"
  gem "unicorn"
end

group :recorder do
  gem "bunny"
  gem "gli", "1.6.0"
end

group :test do
  gem "rspec"
  gem "rack-test"
  gem "ci_reporter"
  gem "factory_girl"
  gem "timecop"
end
