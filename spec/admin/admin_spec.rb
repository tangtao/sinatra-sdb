require File.dirname(__FILE__) + '/../spec_helper'

describe "AdminApplication" do

  def app
    @app ||= SDB::AdminApplication
  end

  before(:all) do
    dbclean()

    @user = User.make!
    @domain = Domain.make!(:user => @user)
    @item1  = Item.make!(:domain => @domain)
    @attr1 = Attr.make!(:item => @item1)
    
    @sdb = getSdb(@user)
  end

    it "get /admin/" do
      get '/admin/'
      follow_redirect!
      last_response.should be_ok
      last_request.path.should == '/admin/login'
    end

    it "get /admin/login" do
      get '/admin/login'
      last_response.should be_ok
      last_request.path.should == '/admin/login'
    end

    it "post /admin/login" do
      post "/admin/login", {:email => @user.email, :password => 'pass'}
      follow_redirect!
      last_response.should be_ok
      last_request.path.should == '/admin/home'
    end

end
