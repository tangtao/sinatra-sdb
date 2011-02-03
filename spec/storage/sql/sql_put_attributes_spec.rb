require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "PutAttributes Storage" do
  
  before(:all) do
    @store = SDB::Storage::Store.new(SDB::Storage::Mongo.new)
  end

  before(:each) do
    dbclean()
    @i,@attrs = db.createItem_one
  end
  
  it "Put attrs in new item" do
    iname = 'newItem'
    
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :itemName => iname,
            :attributes => [{:name => 'myattr_01', :value => Set.new(['v1','v2'])}] }
    
    @store.PutAttributes(args)
    
    newItem = Item.by_name(db.domain, iname)
    newItem.attrs.count.should == 2
  end

  it "Put attrs with replace" do
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :itemName => @i.name,
            :attributes => [{:name => @attrs[0].name, :value => Set.new(['v1','v2']),:replace => true}] }
    
    @store.PutAttributes(args)
    
    @i.attrs.count.should == 5
    attrs = Attr.all_by_name(@i, @attrs[0].name)
    attrs.map{|a|a.content}.should include('v1','v2')
  end

  it "Put attrs with replace and expected" do
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :itemName => @i.name,
            :attributes => [{:name => @attrs[0].name, :value => Set.new(['v1']),:replace => true}],
            :expecteds =>  [{:name => @attrs[0].name, :value => @attrs[0].content, :exists => false}]
           }
    
    @store.PutAttributes(args)
    
    @i.attrs.count.should == 4
    attrs = Attr.all_by_name(@i, @attrs[0].name)
    attrs.map{|a|a.content}.should include('v1')
  end

end
