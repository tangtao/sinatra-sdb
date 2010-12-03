$:.unshift "./lib"
require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'sinatra-sdb'
require 'sinatra-sdb/tasks'

spec = Gem::Specification.new do |s| 
  s.name = "sinatra-sdb"
  s.version = SDB::VERSION
  s.author = "tangtao"
  s.email = "tangtao@gmail.com"
  s.homepage = "http://github.com/tangtao/sinatra-sdb"
  s.platform = Gem::Platform::RUBY
  s.summary = "An implementation of the Amazon SimpleDB API in Ruby"
  s.files = FileList["{bin,lib,public,examples}/**/*"].to_a +
    FileList["db/migrate/*"].to_a +
    ["Rakefile","sinatra-sdb.yml.example"]
  s.require_path = "lib"
  s.description = File.read("README")
  s.executables = ['sinatra-sdb']
  s.test_files = FileList["{test}/*.rb"].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.add_dependency("sinatra", ">= 1.0")
end

Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end 

namespace :test do
  find_file = lambda do |name|
    file_name = lambda {|path| File.join(path, "#{name}.rb")}
    root = $:.detect do |path|
      File.exist?(file_name[path])
    end
    file_name[root] if root
  end

  TEST_LOADER = find_file['rake/rake_test_loader']
  multiruby = lambda do |glob|
    system 'multiruby', TEST_LOADER, *Dir.glob(glob)
  end

  Rake::TestTask.new(:all) do |test|
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
end
