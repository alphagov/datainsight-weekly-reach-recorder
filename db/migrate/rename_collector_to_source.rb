require "dm-migrations/migration_runner"

migration 2, :renmae_collector_to_source do
  up do
    modify_table :weekly_reach_models do
      drop_column :collector
      add_column :source, String, allow_nil: false
    end
  end
end

