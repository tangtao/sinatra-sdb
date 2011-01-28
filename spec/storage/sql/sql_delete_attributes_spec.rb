require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "DeleteAttributes Storage" do
  
  before(:all) do
    @store = SDB::Storage::Store.new(SDB::Storage::SQL.new)
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

  it "Delete attrs with specify attr_name" do
    args = {:key => @user.key,
            :domainName => @domain.name,
            :itemName => @item1.name,
            :attributes => [{:name => @attr1_2.name}] }
    
    @store.DeleteAttributes(args)
    
    @item1.attrs.count.should == 1
    @item1.attrs[0].name.should == @attr1_1.name
  end

  it "Delete attrs with specify attr_name and attr_value" do
    args = {:key => @user.key,
            :domainName => @domain.name,
            :itemName => @item1.name,
            :attributes => [{:name => @attr1_2.name, :value => Set.new(@attr1_2.content)}] }
    
    @store.DeleteAttributes(args)
    
    @item1.attrs.count.should == 2
    @item1.attrs.map{|a|a.content}.should include(@attr1_1.content,@attr1_2x.content)
  end

  it "Delete attrs with expected" do
    args = {:key => @user.key,
            :domainName => @domain.name,
            :itemName => @item1.name,
            :attributes => [{:name => @attr1_2.name, :value => Set.new(@attr1_2.content)}],
            :expecteds =>  [{:name => @attr1_1.name, :value => @attr1_1.content, :exists => false}]
           }
    
    @store.DeleteAttributes(args)
    
    @item1.attrs.count.should == 2
    @item1.attrs.map{|a|a.content}.should include(@attr1_1.content,@attr1_2x.content)
  end

  it "Delete all attrs with a item, item should be deleted" do
    args = {:key => @user.key,
            :domainName => @domain.name,
            :itemName => @item1.name,
            :attributes => [{:name => @attr1_1.name},{:name => @attr1_2.name}]
           }
    
    @store.DeleteAttributes(args)
    
    @domain.items.count.should == 0
  end

  it "direct Delete a item" do
    args = {:key => @user.key,
            :domainName => @domain.name,
            :itemName => @item1.name
           }
    
    @store.DeleteAttributes(args)
    
    @domain.items.count.should == 0
  end
  

end
