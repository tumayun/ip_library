module IPLibrary
  Dir["#{File.dirname(__FILE__)}/ip_library/*.rb"].each { |ext| require ext }
end
