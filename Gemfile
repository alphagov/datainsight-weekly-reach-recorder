source "https://rubygems.org"
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem "rake"
gem "datainsight_recorder", "0.1.1"
gem "datainsight_logging", "0.0.3"
gem "airbrake", "3.1.5"

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
