require "datainsight_recorder/datamapper_config"

module DataMapperConfig
  extend DataInsight::Recorder::DataMapperConfig

  def self.development_uri
    'mysql://root:@localhost/datainsight_weekly_reach'
  end

  def self.production_uri
    'mysql://datainsight:@localhost/datainsight_weekly_reach'
  end

  def self.test_uri
    'mysql://datainsight:@localhost/datainsight_weekly_reach_test'
  end
end
