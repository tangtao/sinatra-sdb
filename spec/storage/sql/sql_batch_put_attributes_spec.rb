require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "BatchPutAttributes Storage" do
  
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
  
  it "Put attrs in new item" do
    iname = 'newItem'
    args = {:key => @user.key,
            :domainName => @domain.name,
            :items_attrs => [ [iname, [ {:name => 'myattr_01', :value => Set.new(['v1','v2'])}] ]
                            ] 
          }
    
    @store.BatchPutAttributes(args)
    
    newItem = @domain.items.find_by_name(iname)
    newItem.attrs.count.should == 2
  end

  it "Put attrs in tow item" do
    iname1 = 'newItem1'
    iname2 = 'newItem2'
    args = {:key => @user.key,
            :domainName => @domain.name,
            :items_attrs => [ [iname1, [ {:name => 'myattr_01', :value => Set.new(['v1','v2'])}] ],
                              [iname2, [ {:name => 'myattr_01', :value => Set.new(['v1','v2'])}] ]
                            ] 
          }
    
    @store.BatchPutAttributes(args)
    
    @domain.items.count.should == 3
    newItem1 = @domain.items.find_by_name(iname1)
    newItem1.attrs.count.should == 2
    newItem2 = @domain.items.find_by_name(iname2)
    newItem2.attrs.count.should == 2

  end

  it "Put attrs with replace" do
    iname = @item1.name
    args = {:key => @user.key,
            :domainName => @domain.name,
            :itemName => @item1.name,
            :items_attrs => [ [iname, [ {:name => @attr1_1.name, :value => Set.new(['v1','v2']), :replace => true}] ]
                            ] 
          }
    
    @store.BatchPutAttributes(args)
    
    newItem = @domain.items.find_by_name(iname)
    newItem.attrs.count.should == 4
  end

end
