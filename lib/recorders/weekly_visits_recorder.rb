require 'bundler/setup'
Bundler.require

require 'bunny'
require 'json'

require_relative "../weekly_visits_model"

module Recorders
  class WeeklyVisitsRecorder

    def initialize(logger)
      @logger = logger
    end

    def run
      queue.subscribe do |msg|
        @logger.debug("Received a message: #{msg}")
        process_message(JSON.parse(msg[:payload], :symbolize_names => true))
      end
    end

    def process_message(msg)
      weekly_visits = WeeklyVisits.first(
          :start_at => parse_start_at(msg[:payload][:start_at]),
          :end_at => parse_end_at(msg[:payload][:end_at]),
          :site => msg[:payload][:site]
      )
      if weekly_visits
        weekly_visits.value = msg[:payload][:value]
        weekly_visits.save
      else
        WeeklyVisits.create(
            :value => msg[:payload][:value],
            :start_at => parse_start_at(msg[:payload][:start_at]),
            :end_at => parse_end_at(msg[:payload][:end_at]),
            :collected_at => DateTime.parse(msg[:envelope][:collected_at]),
            :site => msg[:payload][:site]
        )
      end
    end

    private
    def queue
      @queue ||= create_queue
    end

    def create_queue
      client = Bunny.new ENV['AMQP']
      client.start
      queue = client.queue(ENV['QUEUE'] || 'weekly_visits')
      exchange = client.exchange('datainsight', :type => :topic)

      queue.bind(exchange, :key => 'google_analytics.visits.weekly')
      @logger.info("Bound to google_analytics.visits.weekly, listening for events")

      queue.bind(exchange, :key => 'google_drive.visits.weekly')
      @logger.info("Bound to google_drive.visits.weekly, listening for events")

      queue
    end

    def parse_start_at(start_at)
      Date.parse(start_at)
    end

    # This recorder stores start and end as dates while the message format uses date times on date boundaries (midnight).
    # This means that the date may have to be shifted back
    def parse_end_at(end_at)
      end_at = DateTime.parse(end_at)
      if (end_at.hour + end_at.minute + end_at.second) == 0
        # up to midnight, so including the previous day
        end_at.to_date - 1
      else
        end_at.to_date
      end
    end

  end
end
