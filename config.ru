require "./lib/app"

# Write the access log to a file. We're not using the normal logger, as the format is different.
use Rack::CommonLogger, File.new('log/rack-access.log', 'a')

run Sinatra::Application
