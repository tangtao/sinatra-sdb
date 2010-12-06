require File.dirname(__FILE__) + '/spec_helper'

describe "GetAttributes Action" do
  
  before(:each) do
  end
  
  describe "All" do
    
    it "Get Success" do
      attr1 = Attr.make!
      item = attr1.item
      domain = item.domain
      user = domain.user
      
      sdb = getSdb(user)
      
      link = sdb.get_attributes_link(domain.name, item.name)
      
      get link
      #pp last_response.body
  
      last_response.should be_ok
      checkResponse(last_response.body, 'Name').should == [attr1.name]
      checkResponse(last_response.body, 'Value').should == [attr1.content]
    end
  end

end
