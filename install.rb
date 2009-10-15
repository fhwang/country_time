# Install hook code here
puts "The list of countries provided by this plugin may offend some users. Please review it carefully before you use it"

require 'fileutils'
require 'pathname'

outer = File.dirname(__FILE__)

# Delete test_rails_app directory, unless you're actually developing # country_time itself
test_rails_app = Pathname.new("#{outer}/test_rails_app").realpath.to_s
unless RAILS_ROOT == test_rails_app
  FileUtils.rm_rf "#{outer}/test_rails_app"
end
