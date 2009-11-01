require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run all specs across all tested configuration.'
task :default => :spec

desc 'Run all specs across all tested configuration.'
task :spec do
  config_dir = "./test_rails_app/config/country_time/"
  configurations = Dir.entries(config_dir).map { |entry|
    entry =~ /(\d+).rb$/
    $1.to_i if $1
  }.compact
    cmd = "cd test_rails_app && " + (configurations.map { |config|
    "echo '==== Testing config #{config} =====' && COUNTRY_TIME_CONFIG=#{config} rake"
  }.join(" && "))
  puts cmd
  puts
  puts `#{cmd}`
end

