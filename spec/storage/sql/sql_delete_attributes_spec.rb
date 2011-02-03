require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "DeleteAttributes Storage" do
  
  before(:all) do
    @store = SDB::Storage::Store.new(SDB::Storage::Mongo.new)
  end

  before(:each) do
    dbclean()
    @i,@attrs = db.createItem_one
  end

  it "Delete attrs with specify attr_name" do
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :itemName => @i.name,
            :attributes => [{:name => @attrs[0].name}] }
    
    @store.DeleteAttributes(args)
    
    @i.reload
    @i.attrs.count.should == 3
  end

  it "Delete attrs with specify attr_name and attr_value" do
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :itemName => @i.name,
            :attributes => [{:name => @attrs[1].name, :value => Set.new(@attrs[1].content)}] }
    
    @store.DeleteAttributes(args)
    
    @i.reload
    @i.attrs.count.should == 3
    @i.attrs.map{|a|a.content}.should_not include(@attrs[1].content)
  end

  it "Delete attrs with expected" do
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :itemName => @i.name,
            :attributes => [{:name => @attrs[1].name, :value => Set.new(@attrs[1].content)}],
            :expecteds =>  [{:name => @attrs[0].name, :value => @attrs[0].content, :exists => false}]
           }
    
    @store.DeleteAttributes(args)
    
    @i.reload
    @i.attrs.count.should == 3
    @i.attrs.map{|a|a.content}.should_not include(@attrs[1].content)
  end

  it "Delete all attrs with a item, item should be deleted" do
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :itemName => @i.name,
            :attributes => @attrs.map{|a| {:name => a.name} }
           }
    
    @store.DeleteAttributes(args)
    
    db.domain.items.count.should == 0
  end

  it "direct Delete a item" do
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :itemName => @i.name,
           }
    
    @store.DeleteAttributes(args)
    
    db.domain.items.count.should == 0
  end
  

end
