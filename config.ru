$:.unshift "./lib"
require 'sinatra-sdb'

run SDB::MainApplication
