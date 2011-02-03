require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "QueryWithAttributes Action" do
  
  before(:each) do
    dbclean()
  end
  
  describe "All" do
    
    it "Single query without AttributeName" do
      user = User.make!
      domain = Domain.make!(:user => user)
      item  = Item.make!(:domain => domain)
      attr1 = Attr.make!(:item => item)
      sdb = getSdb(user)
      query_expression = "['#{attr1.name}'='#{attr1.content}']"
      link = sdb.query_with_attributes_link(domain.name, [], query_expression)

      get link

      last_response.should be_ok
      checkResponse(last_response.body, 'ItemName').should == [item.name]
    end

    it "Single query with AttributeName" do
      user = User.make!
      domain = Domain.make!(:user => user)
      item  = Item.make!(:domain => domain)
      attr1 = Attr.make!(:item => item)
      attr2 = Attr.make!(:item => item)
      sdb = getSdb(user)
      query_expression = "['#{attr1.name}'='#{attr1.content}']"
      attr_names = [attr1.name]
      link = sdb.query_with_attributes_link(domain.name, attr_names, query_expression)

      get link
      #pp last_response.body

      last_response.should be_ok
      checkResponse(last_response.body, 'ItemName').should == [item.name]
      checkResponse(last_response.body, 'Attribute Name').count.should == 1
    end

  end

end
