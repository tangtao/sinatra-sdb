require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GetAttributes Storage" do
  
  before(:all) do
    @store = SDB::Storage::Store.new(SDB::Storage::SQL.new)
    dbclean()
  
    @attr1_1 = Attr.make!
    @item1 = @attr1_1.item
    @domain = @item1.domain
    @user = @domain.user

    @attr1_2  = Attr.make!(:item => @item1)
    @attr1_2x  = Attr.make!(:item => @item1, :name => @attr1_2.name)
  end

  it "get all attrs" do
    args = {:key => @user.key,
            :domainName => @domain.name,
            :itemName => @item1.name }
    
    attrs = @store.GetAttributes(args)
    
    attrs.count.should == @item1.attrs.count
  end

end
