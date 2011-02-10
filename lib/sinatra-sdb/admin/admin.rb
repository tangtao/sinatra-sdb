require "sinatra/reloader"
require "sinatra/flash"
require 'erb'

module SDB

  class AdminApplication < Sinatra::Base
    
    use Rack::MethodOverride

    helpers do
      include SDB::AdminHelpers
    end

    set :views, File.dirname(__FILE__) + '/views'
    enable :sessions
    register Sinatra::Flash
    set :storage, Storage::Default.new

    before do
      #ActiveRecord::Base.verify_active_connections!
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
        flash[:error] = "login error!"
        redirect '/admin/login'
      end
    end

    get '/admin/logout' do
      session[:user_id] = nil
      flash[:error] = "login out."
      redirect '/admin/home'
    end

    get '/admin/home' do
      login_required
      @user = curr_user
      @domains = @user.domains.map {|d| [d.name, settings.storage.domain_metadata(curr_user.key, d.name)]}
      r :home, "Home"
    end

    get '/admin/profile' do
      login_required
      redirect "/admin/users/#{curr_user.id}/edit"
    end

    get '/admin/users/new' do
      login_required
      login_only_admin
      r :user_new, "new User"
    end

    post '/admin/users' do
      login_required
      login_only_admin
      @user = User.create(:email => params[:email], :password => params[:password])
      redirect '/admin/users'
    end

    get '/admin/users/?' do
      login_required
      login_only_admin
      @users = User.find(:all)
      r :user_index, "List Users"
    end

    get '/admin/users/:id/edit' do
      login_required
      login_only_admin_and_curr_user(params[:id])
      @user = User.find(params[:id])
      r :user_edit, "Edit User"
    end

    delete '/admin/users/:id' do
      login_required
      login_only_admin
      User.destroy(params[:id])
      redirect '/admin/users'
    end

    put '/admin/users/:id' do
      login_required
      login_only_admin_and_curr_user(params[:id])
      @user = User.find(params[:id])
      @user.attributes = params[:u]
      @user.save
      redirect '/admin/users'
    end
    
  end
end
