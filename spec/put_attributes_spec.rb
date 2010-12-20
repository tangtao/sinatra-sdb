require File.dirname(__FILE__) + '/spec_helper'

describe "PutAttributes Action" do
  
  before(:all) do
    dbclean()
  end
  
  describe "All" do
    
    it "Put Success" do
      attr1 = Attr.make
      item = Item.make!
      domain = item.domain
      user = domain.user
      
      sdb = getSdb(user)
      
      attrs = { attr1.name => attr1.content }
      
      link = sdb.put_attributes_link(domain.name, item.name, attrs)
      get link
      #pp last_response.body
      last_response.should be_ok
      item.attrs.count.should == 1
      item.attrs[0].name.should == attr1.name
      item.attrs[0].content.should == attr1.content
    end
  end

end
