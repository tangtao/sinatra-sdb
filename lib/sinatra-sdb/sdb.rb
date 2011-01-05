require 'rubygems'
require 'bundler'

Bundler.require

require 'active_record'

require 'fileutils'
require 'sinatra/base'
require 'openssl'
require 'base64'
require 'digest/sha1'
require 'digest/md5'
require 'pp'

module SDB
  #S3_ENV = :production
  SDB_ENV = ENV['SDB_ENV'] || 'development'
  

  def self.config
    @config ||= YAML.load_file("sinatra-sdb.yml")[SDB_ENV.to_sym] rescue { 
          :db => { :adapter => 'sqlite3', :database => "db/sdb.sqlite" }
    }
  end

  VERSION = "0.01"

  ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  PUBLIC_PATH = File.expand_path(SDB.config[:public_path] || File.join(ROOT_DIR, 'public'))
end

curr_dir = File.dirname(__FILE__)
%w(base_executor query_expression select_parser select_evaluator select_executor).each {|r| require "#{curr_dir}/parser/#{r}"}
%w(sql).each {|r| require "#{curr_dir}/storage/#{r}"}
%w(errors helpers xmlrender param_builder param_check action main).each {|r| require "#{curr_dir}/#{r}"}
%w(attr item domain user).each {|r| require "#{curr_dir}/models/#{r}"}
