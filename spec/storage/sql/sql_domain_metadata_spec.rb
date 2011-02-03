require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "DomainMetadata Storage" do
  
  before(:all) do
    @store = SDB::Storage::Store.new(SDB::Storage::Mongo.new)
  end

  before(:each) do
    dbclean()

    @user = User.make!
    @domain = Domain.make!(:user => @user)
    @item1  = Item.make!(:domain => @domain)
  
    @attr1_1 = Attr.make!(:item => @item1)
    @attr1_2  = Attr.make!(:item => @item1)
    @attr1_2x  = Attr.make!(:item => @item1, :name => @attr1_2.name)
  end
  
  it "get data" do
    args = {:key => @user.key,
            :domainName => @domain.name
           }
    
    r = @store.DomainMetadata(args)
    
    r["ItemCount"].should == 1
    r["ItemNamesSizeBytes"].should == @item1.name.size
    r["AttributeNameCount"].should == 2
    r["AttributeNamesSizeBytes"].should == @attr1_1.name.size + @attr1_2.name.size
    r["AttributeValueCount"].should == 3
    r["AttributeValuesSizeBytes"].should == (@attr1_1.content + @attr1_2.content + @attr1_2x.content).size
    
  end

end
