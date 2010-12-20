require File.dirname(__FILE__) + '/spec_helper'

describe "DeleteAttributes Action" do
  
  before(:all) do
    dbclean()
  end
  
  describe "All" do
    
    it "Delete Success" do
      attr1 = Attr.make!
      item = attr1.item
      domain = item.domain
      user = domain.user
      
      item.attrs.count.should == 1
      
      sdb = getSdb(user)
      
      attrs = { attr1.name => attr1.content }
      
      link = sdb.delete_attributes_link(domain.name, item.name, attrs)
      get link
      #pp last_response.body
      last_response.should be_ok
      item.attrs.count.should == 0
    end
  end

end
