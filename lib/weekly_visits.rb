require "bundler"
Bundler.require

require 'json'

class WeeklyVisits
  attr_accessor :content
  def initialize(filename = "weekly_visits.json")
    File.open(filename, 'r') do |handle|
      payload = JSON.parse(handle.gets)['payload']
      @content = payload['content']
    end
  end
end
