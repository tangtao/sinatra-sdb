require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "BatchPutAttributes Storage" do
  
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
            :items_attrs => [ [iname, [ {:name => 'myattr_01', :value => Set.new(['v1','v2'])}] ]
                            ] 
          }
          
    
    @store.BatchPutAttributes(args)
    
    newItem = Item.by_name(db.domain, iname)
    newItem.attrs.count.should == 2
  end

  it "Put attrs in two item" do
    iname1 = 'newItem1'
    iname2 = 'newItem2'
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :items_attrs => [ [iname1, [ {:name => 'myattr_01', :value => Set.new(['v1','v2'])}] ],
                              [iname2, [ {:name => 'myattr_01', :value => Set.new(['v1','v2'])}] ]
                            ] 
          }

    
    @store.BatchPutAttributes(args)
    
    db.domain.items.count.should == 3
    newItem1 = Item.by_name(db.domain, iname1)
    newItem1.attrs.count.should == 2
    newItem2 = Item.by_name(db.domain, iname2)
    newItem2.attrs.count.should == 2

  end

  it "Put attrs with replace" do
    iname = @i.name
    args = {:key => db.user.key,
            :domainName => db.domain.name,
            :items_attrs => [ [iname, [ {:name => @attrs[0].name, :value => Set.new(['v1','v2']), :replace => true}] ]
                            ] 
          }
    
    @store.BatchPutAttributes(args)
    
    newItem = Item.by_name(db.domain, iname)
    newItem.attrs.count.should == 5
  end

end
