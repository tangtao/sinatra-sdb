require 'spork'
require "#{File.dirname(__FILE__)}/data_maker_helper"

module SDB
  module SpecHelpers

    protected
    def app
      @app ||= SDB::MainApplication
    end

    def db
      @db ||= SDB::DataMaker.new
    end

    def getStore
      SDB::Store.new(SDB::Storage::Mongo.new)
    end

    def getSdb(user)
      logger = Logger.new('/dev/null')
      params = {:server => 'example.org', :logger => logger}
      sdb = RightAws::SdbInterface.new(user.key, user.secret, params)
    end

    def checkResponse(s, c)
      doc = Nokogiri::XML(s)
      doc.css(c).map do |link|
        link.content
      end
    end

    def dbclean
      #DatabaseCleaner.clean
      ::Mongoid.master.collections.each { |c| c.remove }
    end

  end
end

Spork.prefork do
  ENV['SDB_ENV'] = 'test'

  require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatra-sdb.rb')
  require 'rack/test'
  #require 'spec/autorun'
  #require 'spec/interop/test'
  #require 'database_cleaner'
  require 'support/blueprints'
  curr_dir = File.dirname(__FILE__)
  %w(right_sdb_interface_ext).each {|r| require "#{curr_dir}/ext/#{r}"}
  
  # set test environment
  set :environment, :test
  set :run, false
  set :raise_errors, true
  set :logging, true

  RSpec.configure do |config|
  
    config.include Rack::Test::Methods
    config.include SDB::SpecHelpers
  
    config.before(:suite) do
      #DatabaseCleaner.strategy = :transaction
      #DatabaseCleaner.strategy = :truncation
      #DatabaseCleaner.clean_with(:truncation)
    end
  
    config.before(:each) do
      #DatabaseCleaner.start
      #Machinist.reset_before_test
    end
  
    config.after(:each) do
      #DatabaseCleaner.clean
    end
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.

end
