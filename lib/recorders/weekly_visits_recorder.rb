require 'bundler/setup'
Bundler.require

require 'bunny'
require 'json'

require_relative "../../lib/weekly_visits_model"

module Recorders
  class WeeklyVisitsRecorder

    def initialize(logger)
      @logger = logger
      client = Bunny.new ENV['AMQP']
      client.start
      @queue = client.queue(ENV['QUEUE'] || '_weekly_visits_')
      exchange = client.exchange('datainsight', :type => :topic)

      @queue.bind(exchange, :key => 'google_analytics.visits.weekly')
      @logger.info("Bound to google_analytics.visits.weekly, listening for events")

      @queue.bind(exchange, :key => 'google_drive.visits.weekly')
      @logger.info("Bound to google_drive.visits.weekly, listening for events")
    end

    def run
      @queue.subscribe do |msg|
        @logger.debug("Received a message #{msg}")
        WeeklyVisitsRecorder.process_message(JSON.parse(msg[:payload], :symbolize_names => true))
      end
    end

    def self.process_message(msg)
      WeeklyVisits.create(
          :value => msg[:payload][:value],
          :week_starting => Date.parse(msg[:payload][:week_starting]),
          :collected_at => DateTime.parse(msg[:envelope][:collected_at]),
          :site => msg[:payload][:site]
      )
    end
  end
end
