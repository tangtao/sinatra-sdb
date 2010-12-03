require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'active_record'
require 'logger'

require File.join(File.dirname(__FILE__), 'sdb')

namespace :db do
  task :environment do
    #require 'active_record'
    ActiveRecord::Base.establish_connection(SDB.config[:db])
  end

  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true

    out_dir = File.dirname(SDB.config[:db][:database])
    FileUtils.mkdir_p(out_dir) unless File.exists?(out_dir)

    ActiveRecord::Migrator.migrate(File.join(SDB::ROOT_DIR, 'db', 'migrate'), ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    
    num_users = User.count || 0 
    if num_users == 0
      puts "** No users found, creating the `admin' user."
      User.create :login => "admin", :name => 'admin',
                	:email => "admin@xxxxxx.com", :created_at => Time.now, :updated_at => Time.now
    end
    
  end
end
