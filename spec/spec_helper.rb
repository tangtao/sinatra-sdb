require 'spork'
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
end

Spork.each_run do
  # This code will be run each time you run your specs.
end


ENV['SDB_ENV'] = 'test'
require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatra-sdb.rb')
require 'rack/test'
#require 'spec/autorun'
#require 'spec/interop/test'
require 'database_cleaner'
require 'support/blueprints'
Dir["#{File.dirname(__FILE__)}/helper/*.rb"].each {|r| require r }

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, true

module SDB
  module SpecHelpers

    protected
    def app
      @app ||= SDB::MainApplication
    end

    def getSdb(user)
      logger = Logger.new('/dev/null')
      params = {:server => 'localhost', :logger => logger}
      sdb = RightAws::SdbInterface.new(user.key, user.secret, params)
    end

    def checkResponse(s, c)
      doc = Nokogiri::XML(s)
      doc.css(c).map do |link|
        link.content
      end
    end

  end
end

RSpec.configure do |config|

  config.include Rack::Test::Methods
  config.include SDB::SpecHelpers

  config.before(:suite) do
    #DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.strategy = :truncation
    #DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    #DatabaseCleaner.start
    #Machinist.reset_before_test
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

