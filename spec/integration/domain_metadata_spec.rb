require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "DomainMetadata Action" do
  
  before(:all) do
    dbclean()
  end
  
  describe "All" do
    
    it "Success" do
      user = User.make!
      domain = Domain.make!(:user => user)
      item1  = Item.make!(:domain => domain)
      attr1 = Attr.make(:item => item1)
      sdb = getSdb(user)
      link = sdb.domain_metadata_link(domain.name)
      
      get link
      #pp last_response
  
      last_response.should be_ok
      checkResponse(last_response.body, 'ItemCount').should == ['1']
    end
  end

end
