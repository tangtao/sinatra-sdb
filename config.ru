$:.unshift "./lib"
require 'sinatra-sdb'

use SDB::AdminApplication
run SDB::MainApplication
