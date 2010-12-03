require File.dirname(__FILE__) + '/spec_helper'

describe "main.rb" do
  include Rack::Test::Methods
 
  def app
    @app ||= SDB::MainApplication
  end
  
  before(:each) do
    @user = Factory.create(:user) # returns a saved object
    @sdb = getSdb(@user)
  end
  
  describe "CreateDomain Action" do
    
    it "Create Success" do
      @user.domains.count.should == 0
  
      link = @sdb.create_domain_link('books')
      get link
  
      last_response.should be_ok
      @user.domains.count.should == 1
    end
    
    it "Create repeat with same domain name" do
      @user.domains.count.should == 0
  
      link = @sdb.create_domain_link('books')
      get link
      last_response.should be_ok
      @user.domains.count.should == 1
      
      link2 = @sdb.create_domain_link('books')
      get link2
  
      last_response.should be_ok
      @user.domains.count.should == 1
    end
  
  end

  describe "ListDomains Action" do
    
    it "List Success" do
      domain = Factory.create(:domain)
      ux = domain.user
      @user.domains.count.should == 0
      ux.domains.count.should == 1
  
      sdb = getSdb(ux)

      link = sdb.list_domains_link()
      
      get link
  
      last_response.should be_ok
      checkResponse(last_response.body, 'DomainName').should == [domain.name]
    end
  end

  describe "DeleteDomain Action" do
    
    it "Delete Success" do
      domain = Factory.create(:domain)
      ux = domain.user
  
      sdb = getSdb(ux)

      link = sdb.delete_domain_link(domain.name)
      
      get link
  
      last_response.should be_ok
      ux.domains.count.should == 0
    end
  end

  describe "DomainMetadata Action" do
    
    it "Success" do
      domain = Factory.create(:domain)
      ux = domain.user
  
      sdb = getSdb(ux)

      link = sdb.domain_metadata_link(domain.name)
      
      get link
      #pp last_response
  
      last_response.should be_ok
      checkResponse(last_response.body, 'ItemCount').should == ['0']
    end
  end
  
  def getSdb(user)
    logger = Logger.new('/dev/null')
    params = {:server => 'localhost', :logger => logger}
    sdb = RightAws::SdbInterface.new(user.key, user.secret, params)
  end
  def checkResponse(s, c)
    doc = Nokogiri::XML(s)
    doc.css(c).map do |link|
      link.content
    end
  end

end
