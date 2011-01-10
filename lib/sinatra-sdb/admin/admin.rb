require "sinatra/reloader"
require 'erb'

module SDB

  class AdminApplication < Sinatra::Base

    helpers do
      include SDB::AdminHelpers
    end

    set :views, File.dirname(__FILE__) + '/views'
    enable :sessions

    before do
      ActiveRecord::Base.verify_active_connections!
    end
    configure(:development, :test) do
      register Sinatra::Reloader
      also_reload "./lib/sinatra-sdb/admin/*.rb"
    end

    get '/admin/?' do
      login_required
      redirect '/admin/home'
    end

    get '/admin/login' do
      r :login, "Login"
    end

    post '/admin/login' do
      @user = User.authenticate(params[:email], params[:password])
      if @user
        session[:user_id] = @user.id
        redirect '/admin/home'
      else
        @user = User.new
        @user.errors.add(:login, 'not found')
      end
    end

    get '/admin/home' do
      login_required
      r :home, "Home"
    end

  end
end
