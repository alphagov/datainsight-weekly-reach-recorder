require 'dm-constraints'
require 'dm-migrations'

module DataMapperConfig
  def self.configure_development
    DataMapper::Logger.new($stdout, :debug)
    DataMapper.setup(:default, 'mysql://root:@localhost/datainsights-weekly-visits')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  def self.configure_production
    DataMapper.setup(:default, 'mysql://root:@localhost/datainsights-weekly-visits')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  def self.configure_test
    DataMapper.setup(:default, 'sqlite::memory:')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end
end
