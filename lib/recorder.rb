require 'json'

require 'bundler/setup'
Bundler.require(:default, :recorder)
require "datainsight_recorder/recorder"

require_relative "model"

module WeeklyReach
  class Recorder
    include DataInsight::Recorder::AMQP

    def queue_name
      "datainsight_weekly_reach_recorder"
    end

    def routing_keys
      [
        "google_analytics.visits.weekly",
        "google_analytics.visitors.weekly",
        "google_drive.visits.weekly",
        "google_drive.visitors.weekly"
      ]
    end

    def update_message(message)
      WeeklyReach::Model.update_from_message(message)
    end
  end
end