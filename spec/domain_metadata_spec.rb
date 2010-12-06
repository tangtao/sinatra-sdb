require File.dirname(__FILE__) + '/spec_helper'

describe "DomainMetadata Action" do
  
  before(:each) do
    @user = User.make!
  end
  
  describe "All" do
    
    it "Success" do
      domain = Domain.make!
      ux = domain.user
      sdb = getSdb(ux)
      link = sdb.domain_metadata_link(domain.name)
      
      get link
      #pp last_response
  
      last_response.should be_ok
      checkResponse(last_response.body, 'ItemCount').should == ['0']
    end
  end

end
