require "dm-migrations/migration_runner"
require_relative "../../lib/model"

migration 3, :delete_weekly_reach_data do
  up do
    WeeklyReach::Model.destroy
  end
end