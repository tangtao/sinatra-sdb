require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "GetAttributes Action" do
  
  before(:all) do
    dbclean()
    @attr1 = Attr.make!
    @item = @attr1.item
    @attr2  = Attr.make!(:item => @item)
    @domain = @item.domain
    @user = @domain.user
    @sdb = getSdb(@user)
  end
  
  describe "Base" do
    
    it "Simple Get" do
      link = @sdb.get_attributes_link(@domain.name, @item.name)
      
      get link
  
      last_response.should be_ok
      checkResponse(last_response.body, 'Name').should include(@attr1.name, @attr2.name)
      checkResponse(last_response.body, 'Value').should include(@attr1.content, @attr2.content)
    end

    it "Simple Get with Attribute Name" do
      link = @sdb.get_attributes_link(@domain.name, @item.name, [@attr1.name])
      
      get link
  
      last_response.should be_ok
      checkResponse(last_response.body, 'Name').should include(@attr1.name)
      checkResponse(last_response.body, 'Name').should_not include(@attr2.name)
      checkResponse(last_response.body, 'Value').should include(@attr1.content)
      checkResponse(last_response.body, 'Value').should_not include(@attr2.content)
    end

    it "NoItemName return empty set" do
      link = @sdb.get_attributes_link(@domain.name, @item.name + "xx")
      get link
      last_response.should be_ok
    end

  end

  describe "Error" do
    it "NoSuchDomain" do
      link = @sdb.get_attributes_link(@domain.name + "xx", @item.name)
      get link
      last_response.should_not be_ok
      last_response.body.should == "The specified domain does not exist."
    end

  end

end
