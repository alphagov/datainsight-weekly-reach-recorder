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
        begin
          @logger.debug("Received a message: #{msg}")
          process_message(parse_amqp_message(msg))
        rescue Exception => e
          @logger.error("#{e} \n" + e.backtrace.join("\n"))
        end
      end
    end

    def process_message(message)
      validate_message(message)
      params = {
          :metric => parse_metric(message[:envelope][:_routing_key]),
          :start_at => parse_start_at(message[:payload][:start_at]),
          :end_at => parse_end_at(message[:payload][:end_at]),
          :site => message[:payload][:site]
      }
      weekly_visits = Model.first(params)
      if message[:payload][:value].nil?
        if weekly_visits
          weekly_visits.destroy
        end
      else
        if weekly_visits
          weekly_visits.value = message[:payload][:value]
          weekly_visits.collected_at = message[:envelope][:collected_at]
          weekly_visits.save
        else
          Model.create(
              :value => message[:payload][:value],
              :metric => parse_metric(message[:envelope][:_routing_key]),
              :start_at => parse_start_at(message[:payload][:start_at]),
              :end_at => parse_end_at(message[:payload][:end_at]),
              :collected_at => DateTime.parse(message[:envelope][:collected_at]),
              :site => message[:payload][:site]
          )
        end
      end
    end

    private
    def validate_message(message)
      raise "No value provided in message payload: #{message.inspect}" unless message[:payload].has_key? :value
      unless message[:payload][:value].nil? or message[:payload][:value].is_a? Integer
        raise "Invalid value provided in message payload: #{message.inspect}"
      end
    end

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
