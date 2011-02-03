require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "BatchPutAttributes Action" do
  
  before(:each) do
    dbclean()
  end
  
  describe "All" do
    
    it "Put One attr in a exist item Success" do

      user = User.make!
      domain = Domain.make!(:user => user)
      item1  = Item.make!(:domain => domain)
  
      attr1 = Attr.make(:item => item1)
      
      sdb = getSdb(user)
      item_attrs = [item1.name, { attr1.name => attr1.content }]
      link = sdb.batch_put_attributes_link(domain.name, [item_attrs], true)

      get link
      #pp last_response.body

      last_response.should be_ok
      item1.attrs.count.should == 1
      item1.attrs.map{|a| a.name}.should include(attr1.name)
      item1.attrs.map{|a| a.content}.should include(attr1.content)
    end

    it "Put multi attrs in multi exist items Success" do
      user = User.make!
      domain = Domain.make!(:user => user)
      item1  = Item.make!(:domain => domain)
      item2  = Item.make!(:domain => domain)
      
      attr1_1 = Attr.make(:item => @item1)
      attr1_2 = Attr.make(:item => @item1)
      attr2_1 = Attr.make(:item => @item2)
      attr2_2 = Attr.make(:item => @item2)
      
      sdb = getSdb(user)
      item_attrs1 = [item1.name, { attr1_1.name => attr1_1.content, attr1_2.name => attr1_2.content}]
      item_attrs2 = [item2.name, { attr2_1.name => attr2_1.content, attr2_2.name => attr2_2.content}]
      link = sdb.batch_put_attributes_link(domain.name, [item_attrs1, item_attrs2], true)

      get link
      #pp last_response.body

      last_response.should be_ok
      
      item1.attrs.count.should == 2
      item1.attrs.map{|a| a.name}.should include(attr1_1.name, attr1_2.name)
      item1.attrs.map{|a| a.content}.should include(attr1_1.content, attr1_2.content)

      item2.attrs.count.should == 2
      item2.attrs.map{|a| a.name}.should include(attr2_1.name, attr2_2.name)
      item2.attrs.map{|a| a.content}.should include(attr2_1.content, attr2_2.content)

    end

  end

end
