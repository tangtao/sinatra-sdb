require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "SQL Storage" do
  
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

  
  describe "PutAttributes" do
    
    it "Put attrs in new item" do
      iname = 'newItem'
      args = {:key => @user.key,
              :domainName => @domain.name,
              :itemName => iname,
              :attributes => [{:name => 'myattr_01', :value => Set.new(['v1','v2'])}] }
      
      @storage.PutAttributes(args)
      
      newItem = @domain.items.find_by_name(iname)
      newItem.attrs.count.should == 2
    end

    it "Put attrs with replace" do
      args = {:key => @user.key,
              :domainName => @domain.name,
              :itemName => @item1.name,
              :attributes => [{:name => @attr1_2.name, :value => Set.new(['v1','v2']),:replace => true}] }
      
      @storage.PutAttributes(args)
      
      @item1.attrs.count.should == 3
      attrs = @item1.attrs.find_all_by_name(@attr1_2.name)
      attrs.map{|a|a.content}.should include('v1','v2')
    end

    it "Put attrs with replace and expected" do
      args = {:key => @user.key,
              :domainName => @domain.name,
              :itemName => @item1.name,
              :attributes => [{:name => @attr1_1.name, :value => Set.new(['v1']),:replace => true}],
              :expecteds =>  [{:name => @attr1_1.name, :value => @attr1_1.content, :exists => false}]
             }
      
      @storage.PutAttributes(args)
      
      @item1.attrs.count.should == 3
      attrs = @item1.attrs.find_all_by_name(@attr1_1.name)
      attrs.map{|a|a.content}.should include('v1')
    end

  end

  describe "DeleteAttributes" do
    
    it "Delete attrs with specify attr_name" do
      args = {:key => @user.key,
              :domainName => @domain.name,
              :itemName => @item1.name,
              :attributes => [{:name => @attr1_2.name}] }
      
      @storage.DeleteAttributes(args)
      
      @item1.attrs.count.should == 1
      @item1.attrs[0].name.should == @attr1_1.name
    end

    it "Delete attrs with specify attr_name and attr_value" do
      args = {:key => @user.key,
              :domainName => @domain.name,
              :itemName => @item1.name,
              :attributes => [{:name => @attr1_2.name, :value => Set.new(@attr1_2.content)}] }
      
      @storage.DeleteAttributes(args)
      
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
      
      @storage.DeleteAttributes(args)
      
      @item1.attrs.count.should == 2
      @item1.attrs.map{|a|a.content}.should include(@attr1_1.content,@attr1_2x.content)
    end

    it "Delete all attrs with a item, item should be deleted" do
      args = {:key => @user.key,
              :domainName => @domain.name,
              :itemName => @item1.name,
              :attributes => [{:name => @attr1_1.name},{:name => @attr1_2.name}]
             }
      
      @storage.DeleteAttributes(args)
      
      @domain.items.count.should == 0
    end

    it "direct Delete a item" do
      args = {:key => @user.key,
              :domainName => @domain.name,
              :itemName => @item1.name
             }
      
      @storage.DeleteAttributes(args)
      
      @domain.items.count.should == 0
    end
  end

  describe "DomainMetadata" do
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


end
