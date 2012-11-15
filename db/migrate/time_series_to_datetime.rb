require "dm-migrations/migration_runner"

migration 1, :convert_time_series_fields_to_datetime do
  up do
    modify_table :weekly_reach_models do
      change_column :start_at, DateTime, allow_nil: false
      change_column :end_at, DateTime, allow_nil: false
    end
  end
end

