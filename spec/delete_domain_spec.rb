require File.dirname(__FILE__) + '/spec_helper'

describe "DeleteDomain Action" do
  
  before(:each) do
    @user = User.make!
  end
  
  describe "All" do
    
    it "Delete Success" do
      domain = Domain.make!
      sdb = getSdb(domain.user)
      link = sdb.delete_domain_link(domain.name)
      
      get link
  
      last_response.should be_ok
      @user.domains.count.should == 0
    end
  end

end
