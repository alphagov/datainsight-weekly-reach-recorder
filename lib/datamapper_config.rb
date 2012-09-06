require 'dm-constraints'
require 'dm-migrations'

module DataMapperConfig
  def self.configure(env=ENV["RACK_ENV"])
    DataMapper.logger = Logging.logger[DataMapper]
    case (env or "default").to_sym
      when :test
        DataMapperConfig.configure_test
      when :production
        DataMapperConfig.configure_production
      else
        DataMapperConfig.configure_development
    end
    DataMapper::Model.raise_on_save_failure = true
  end

  def self.configure_development
    DataMapper.setup(:default, 'mysql://root:@localhost/datainsights_weekly_reach')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  def self.configure_production
    DataMapper.setup(:default, 'mysql://datainsights:@localhost/datainsight_weekly_reach')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  def self.configure_test
    DataMapper.setup(:default, 'sqlite::memory:')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end
end
