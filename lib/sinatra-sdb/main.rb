require "sinatra/reloader"
module SDB

  class MainApplication < Sinatra::Base

    enable :static
    disable :raise_errors, :show_exceptions
    set :environment, SDB_ENV.to_sym
    set :public, PUBLIC_PATH
    set :myaction, Action.new(XmlRender.new, Storage::SQL.new)

    configure do
      ActiveRecord::Base.establish_connection(SDB.config[:db])
      #ActiveRecord::Base.logger = Logger.new(STDOUT)
    end

    configure(:development, :test) do
      register Sinatra::Reloader
      also_reload "./lib/**/*.rb"
    end

    get '/' do
      #pp request
      settings.myaction.runAction(params,request)
    end

  end

end
