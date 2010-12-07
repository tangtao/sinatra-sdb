require File.dirname(__FILE__) + '/spec_helper'

describe "BatchPutAttributes Action" do
  
  before(:each) do
  end
  
  describe "All" do
    
    it "Put One attr in a exist item Success" do
      attr1 = Attr.make
      item1 = Item.make!
      domain = item1.domain
      user = domain.user
      sdb = getSdb(user)
      item_attrs = [item1.name, { attr1.name => attr1.content }]
      link = sdb.batch_put_attributes_link(domain.name, [item_attrs], true)

      get link
      #pp last_response.body

      last_response.should be_ok
      item1.attrs.count.should == 1
      item1.attrs[0].name.should == attr1.name
      item1.attrs[0].content.should == attr1.content
    end

    it "Put multi attrs in multi exist items Success" do
      item1 = Item.make!
      domain = item1.domain
      user = domain.user
      item2 = Item.make!(:domain => domain)
      domain.items.count.should == 2
      
      attr1_1 = Attr.make
      attr1_2 = Attr.make
      attr2_1 = Attr.make
      attr2_2 = Attr.make
      
      sdb = getSdb(user)
      item_attrs1 = [item1.name, { attr1_1.name => attr1_1.content, attr1_2.name => attr1_2.content}]
      item_attrs2 = [item2.name, { attr2_1.name => attr2_1.content, attr2_2.name => attr2_2.content}]
      link = sdb.batch_put_attributes_link(domain.name, [item_attrs1, item_attrs2], true)
      
      get link
      #pp last_response.body

      last_response.should be_ok
      item1.attrs.count.should == 2
      item1.attrs[0].name.should == attr1_1.name
      item1.attrs[0].content.should == attr1_1.content
      item1.attrs[1].name.should == attr1_2.name
      item1.attrs[1].content.should == attr1_2.content

      item2.attrs.count.should == 2
      item2.attrs[0].name.should == attr2_1.name
      item2.attrs[0].content.should == attr2_1.content
      item2.attrs[1].name.should == attr2_2.name
      item2.attrs[1].content.should == attr2_2.content

    end

  end

end
