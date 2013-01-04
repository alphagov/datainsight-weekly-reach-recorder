require "dm-migrations/migration_runner"

migration 2, :renmae_collector_to_source do
  up do
    modify_table :weekly_reach_models do
      if adapter.field_exists?("weekly_reach_models", "collector")
        drop_column :collector
      end
      unless adapter.field_exists?("weekly_reach_models", "source")
        add_column :source, String, allow_nil: false
      end
    end
  end
end

