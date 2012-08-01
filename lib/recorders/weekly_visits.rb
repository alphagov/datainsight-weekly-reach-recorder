require 'bundler/setup'
Bundler.require

require 'bunny'

module Recorders
  class WeeklyVisitsRecorder

    def initialize(logger)
      @logger = logger
      client = Bunny.new ENV['AMQP']
      client.start
      @queue = client.queue(ENV['QUEUE'] || 'weekly_visits')
      exchange = client.exchange('datainsight', :type => :topic)
      @queue.bind(exchange, :key => '*.weekly_visits')
      @logger.info("Bound to *.weekly_visits, listening for events")
    end

    def run
      @queue.subscribe do |msg|
        @logger.info("Received message: #{msg[:payload]}")
        File.open('weekly_visits.json', 'w') do |handle|
          handle.puts msg[:payload]
        end
      end
    end
  end
end
