require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GetAttributes Storage" do
  
  before(:all) do
    @store = getStore
    dbclean()
    @i,@attrs = db.createItem_one
  
  end

  it "get all attrs" do
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :itemName => @i.name }
    
    attrs = @store.GetAttributes(args)
    attrs.count.should == @attrs.count
    
  end
  
  

end
