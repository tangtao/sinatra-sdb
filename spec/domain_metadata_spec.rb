require File.dirname(__FILE__) + '/spec_helper'

describe "DomainMetadata Action" do
  
  before(:each) do
  end
  
  describe "All" do
    
    it "Success" do
      domain = Domain.make!
      u = domain.user
      sdb = getSdb(u)
      link = sdb.domain_metadata_link(domain.name)
      
      get link
      #pp last_response
  
      last_response.should be_ok
      checkResponse(last_response.body, 'ItemCount').should == ['0']
    end
  end

end
