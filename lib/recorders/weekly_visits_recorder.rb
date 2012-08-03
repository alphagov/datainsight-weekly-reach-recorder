require 'bundler/setup'
Bundler.require

require 'bunny'

module Recorders
  class WeeklyVisitsRecorder

    def initialize(logger)
      @logger = logger
      client = Bunny.new ENV['AMQP']
      client.start
      @analytics_queue = client.queue(ENV['QUEUE'] || 'weekly_visits_analytics')
      @drive_queue = client.queue(ENV['QUEUE'] || 'weekly_visits_drive')
      exchange = client.exchange('datainsight', :type => :topic)
      @analytics_queue.bind(exchange, :key => 'google_analytics.visits')
      @drive_queue.bind(exchange, :key => 'google_drive.visits')
      @logger.info("Bound to google_analytics.visits, listening for events")
      @logger.info("Bound to google_drive.visits, listening for events")
    end

    def run
      @analytics_queue.subscribe do |msg|

      end
      @drive_queue.subscribe do |msg|
        process_drive_message(msg)
      end
    end

    def self.process_drive_message(msg)
      WeeklyVisits.create(
          :value => msg[:payload][:value],
          :week_starting => msg[:payload][:week_starting],
          :collected_at => msg[:envelope][:collected_at],
          :site => msg[:payload][:site]
      )
    end

    def self.process_analytics_message(msg)
      week_start = self.find_week_start(msg[:payload][:start_at])

      current_week_visits = WeeklyVisits.first(:week_starting => week_start, :site => msg[:payload][:site])

      if not current_week_visits
        WeeklyVisits.create(
            :value => msg[:payload][:value],
            :week_starting => week_start,
            :site => msg[:payload][:site]
        )
      else
        WeeklyVisits.update(
            :value => msg[:payload][:value] + (current_week_visits ? current_week_visits.value : 0),
            :week_starting => week_start,
            :site => msg[:payload][:site]
        )
      end
    end

    def self.find_week_start(date)
      while not date.monday?
        date = date.prev_day
      end
      date.to_date
    end
  end
end
