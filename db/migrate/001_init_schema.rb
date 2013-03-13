require "datainsight_recorder/migrations"

migration 1, :init_schema do
  up do
    if adapter.storage_exists?("migration_info")
      # reset data about old migrations
      execute "DELETE FROM migration_info"
    end

    unless adapter.storage_exists?("weekly_reach_models")
      create_table :weekly_reach_models do
        column :id, "INTEGER(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY" # Integer, serial: true
        column :collected_at, DateTime, allow_nil: false
        column :source,       String,   allow_nil: false
        column :start_at,     DateTime, allow_nil: false
        column :end_at,       DateTime, allow_nil: false
        column :metric,       String,   allow_nil: false
        column :site,         String,   allow_nil: false
        column :value,        Integer,  allow_nil: false
      end
    end
  end

  down do
    drop_table :weekly_reach_models
  end
end
