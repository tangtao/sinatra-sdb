require File.dirname(__FILE__) + '/spec_helper'

describe "ListDomains Action" do
  
  before(:each) do
    @user = User.make!
  end
  
  describe "All" do
    
    it "List Something Success" do
      domain = Domain.make!
      ux = domain.user
      ux.domains.count.should == 1
      sdb = getSdb(ux)
      link = sdb.list_domains_link()
      
      get link
  
      last_response.should be_ok
      checkResponse(last_response.body, 'DomainName').should == [domain.name]
    end
  end

end
