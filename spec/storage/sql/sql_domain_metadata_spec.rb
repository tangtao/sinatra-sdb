require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "DomainMetadata Storage" do
  
  before(:all) do
    @storage = SDB::Storage::SQL.new
  end

  before(:each) do
    dbclean()
  
    @attr1_1 = Attr.make!
    @item1 = @attr1_1.item
    @domain = @item1.domain
    @user = @domain.user

    @attr1_2  = Attr.make!(:item => @item1)
    @attr1_2x  = Attr.make!(:item => @item1, :name => @attr1_2.name)
  end
  
  it "get data" do
    args = {:key => @user.key,
            :domainName => @domain.name
           }
    
    r = @storage.DomainMetadata(args)
    
    r["ItemCount"].should == 1
    r["ItemNamesSizeBytes"].should == @item1.name.size
    r["AttributeNameCount"].should == 2
    r["AttributeNamesSizeBytes"].should == @attr1_1.name.size + @attr1_2.name.size
    r["AttributeValueCount"].should == 3
    r["AttributeValuesSizeBytes"].should == (@attr1_1.content + @attr1_2.content + @attr1_2x.content).size
    
  end

end
