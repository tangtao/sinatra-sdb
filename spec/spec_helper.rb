#require 'rubygems'
#require 'spork'

#Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  
#end

#Spork.each_run do
  # This code will be run each time you run your specs.
  
#end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#




ENV['SDB_ENV'] = 'test'
require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatra-sdb.rb')

#require 'rubygems'
#require 'sinatra'
require 'rack/test'
require 'factory_girl'
#require 'spec'
FactoryGirl.find_definitions

#require 'spec/autorun'
#require 'spec/interop/test'

#require 'helper/right_sdb_interface_ext'
require 'database_cleaner'

Dir["#{File.dirname(__FILE__)}/helper/*.rb"].each {|r| require r }

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, true

RSpec.configure do |config|

  config.before(:suite) do
    #DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.strategy = :truncation
    #DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    #DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end


end
