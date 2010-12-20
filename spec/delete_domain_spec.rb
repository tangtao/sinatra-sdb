require File.dirname(__FILE__) + '/spec_helper'

describe "DeleteDomain Action" do
  
  before(:all) do
    dbclean()
  end
  
  describe "All" do
    
    it "Delete Success" do
      domain = Domain.make!
      u = domain.user
      sdb = getSdb(u)
      link = sdb.delete_domain_link(domain.name)
      
      get link
  
      last_response.should be_ok
      u.domains.count.should == 0
    end
  end

end
