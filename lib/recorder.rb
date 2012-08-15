require 'bundler/setup'
Bundler.require

require 'bunny'
require 'json'

require_relative "model"

module WeeklyReach
  class Recorder

    ROUTING_KEYS = %w(google_analytics.visits.weekly google_analytics.visitors.weekly google_drive.visits.weekly google_drive.visitors.weekly)

    def initialize(logger)
      @logger = logger
    end

    def run
      queue.subscribe do |msg|
        @logger.debug("Received a message: #{msg}")
        process_message(parse_amqp_message(msg))
      end
    end

    def process_message(msg)
      params = {
          :metric => parse_metric(msg[:envelope][:_routing_key]),
          :start_at => parse_start_at(msg[:payload][:start_at]),
          :end_at => parse_end_at(msg[:payload][:end_at]),
          :site => msg[:payload][:site]
      }
      weekly_visits = Model.first(params)
      if msg[:payload][:value].nil?
        if weekly_visits
          weekly_visits.destroy
        end
      else
        if weekly_visits
          weekly_visits.value = msg[:payload][:value]
          weekly_visits.collected_at = msg[:envelope][:collected_at]
          weekly_visits.save
        else
          Model.create(
              :value => msg[:payload][:value],
              :metric => parse_metric(msg[:envelope][:_routing_key]),
              :start_at => parse_start_at(msg[:payload][:start_at]),
              :end_at => parse_end_at(msg[:payload][:end_at]),
              :collected_at => DateTime.parse(msg[:envelope][:collected_at]),
              :site => msg[:payload][:site]
          )
        end
      end
    end

    private
    def queue
      @queue ||= create_queue
    end

    def create_queue
      client = Bunny.new ENV['AMQP']
      client.start
      queue = client.queue(ENV['QUEUE'] || 'weekly_reach')
      exchange = client.exchange('datainsight', :type => :topic)

      ROUTING_KEYS.each do |key|
        queue.bind(exchange, :key => key)
        @logger.info("Bound to #{key}, listening for events")
      end

      queue
    end

    def parse_amqp_message(raw_message)
      message = JSON.parse(raw_message[:payload], :symbolize_names => true)
      message[:envelope][:_routing_key] = raw_message[:delivery_details][:routing_key]
      message
    end

    def parse_metric(routing_key)
      /\.(?<metric>visits|visitors)\.weekly$/.match(routing_key)[:metric] or raise "Invalid metric for key [#{routing_key}] "
    end

    def parse_start_at(start_at)
      DateTime.parse(start_at)
    end

    # This recorder stores start and end as dates while the message format uses date times on date boundaries (midnight).
    # This means that the date may have to be shifted back
    def parse_end_at(end_at)
      end_at = DateTime.parse(end_at)
      if (end_at.hour + end_at.minute + end_at.second) == 0
        # up to midnight, so including the previous day
        end_at - 1
      else
        end_at
      end
    end

  end
end
