Dir.glob(File.absolute_path("#{File.dirname(__FILE__)}/../config/initializers/*.rb")).each do |initializer|
  require_relative initializer
end
