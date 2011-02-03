require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Select Action" do
  
  before(:all) do
    dbclean()

    @user = User.make!
    @domain = Domain.make!(:user => @user)
    @item  = Item.make!(:domain => @domain)
    @attr1 = Attr.make!(:item => @item)
    @sdb = getSdb(@user)
  end
  
  it "Return all with single query" do
    select_expression = "select * from #{@domain.name} where #{@attr1.name}='#{@attr1.content}'"
    link = @sdb.select_link(select_expression)

    get link
    #pp last_response.body

    last_response.should be_ok
    checkResponse(last_response.body, 'ItemName').should == [@item.name]
    checkResponse(last_response.body, 'Attribute Name').should == [@attr1.name]
    checkResponse(last_response.body, 'Attribute Value').should == [@attr1.content]
  end

  it "Return count with single query" do
    select_expression = "select count(*) from #{@domain.name} where #{@attr1.name}='#{@attr1.content}'"
    link = @sdb.select_link(select_expression)

    get link
    #pp last_response.body

    last_response.should be_ok
    checkResponse(last_response.body, 'ItemName').should == ["Domain"]
    checkResponse(last_response.body, 'Attribute Name').should == ["Count"]
    checkResponse(last_response.body, 'Attribute Value').should == ["1"]
  end


end
