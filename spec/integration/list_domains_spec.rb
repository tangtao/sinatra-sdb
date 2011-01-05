require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "ListDomains Action" do
  
  before(:all) do
    dbclean()
  end
  
  describe "Base" do
    
    it "List Simple" do
      domain = Domain.make!
      u = domain.user
      sdb = getSdb(u)
      link = sdb.list_domains_link()
    
      get link
  
      last_response.should be_ok
      checkResponse(last_response.body, 'DomainName').should == [domain.name]
    end
  end

end
