require File.dirname(__FILE__) + '/spec_helper'

describe "ListDomains Action" do
  
  before(:each) do
  end
  
  describe "All" do
    
    it "List Something Success" do
      domain = Domain.make!
      u = domain.user
      u.domains.count.should == 1
      sdb = getSdb(u)
      link = sdb.list_domains_link()
      
      get link
  
      last_response.should be_ok
      checkResponse(last_response.body, 'DomainName').should == [domain.name]
    end
  end

end
