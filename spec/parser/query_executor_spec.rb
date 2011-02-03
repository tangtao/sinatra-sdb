require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

  

describe "Query Executor Test" do

  before(:all) do
    dbclean()

    @user = User.make!
    @domain = Domain.make!(:user => @user)
    
    @item1  = Item.make!(:domain => @domain)
    @attr1_1 = Attr.make!(:item => @item1)
    @attr1_Y  = Attr.make!(:item => @item1,:name => 'year', :content => '2009')

    @item2  = Item.make!(:domain => @domain)
    @attr2_1  = Attr.make!(:item => @item2)
    @attr2_2  = Attr.make!(:item => @item2)
    @attr2_3  = Attr.make!(:item => @item2)
    @attr2_3x = Attr.make!(:item => @item2,:name => @attr2_3.name)
    @attr2_Y  = Attr.make!(:item => @item2,:name => 'year', :content => '2010')

    
    @item3 = Item.make!(:domain => @domain)
    @attr3_1  = Attr.make!(:item => @item3, :name => @attr2_1.name, :content => @attr2_1.content)
    @attr3_2  = Attr.make!(:item => @item3)
    @attr3_3  = Attr.make!(:item => @item3, :name => @attr2_3.name, :content => @attr2_3.content)
    @attr3_Y  = Attr.make!(:item => @item3,:name => 'year', :content => '2011')

    @executor = SDB::QueryExecutor.new

  end

  describe "Simple Predicate" do
    describe "Simple attr" do
      it "one attr" do
        query = "['#{@attr1_1.name}' = '#{@attr1_1.content}']"
        items,count = @executor.do_query(@user.key, @domain.name, query)
        count.should be_nil
        items[0].name.should == @item1.name
      end
    end

    describe "Attribute comparison" do
      it "and" do
        query = "['#{@attr2_1.name}' = '#{@attr2_1.content}' and 'year' = '2011']"
        items,count = @executor.do_query(@user.key, @domain.name, query)
        items.count.should == 1
        items[0].name.should == @item3.name
      end

      it "or" do
        query = "['#{@attr2_2.name}' = '#{@attr2_2.content}' or 'year' = '2011']"
        items,count = @executor.do_query(@user.key, @domain.name, query)
        items.count.should == 2
      end

    end

  end

  describe "multiple predicates" do

    it "intersection" do
      query = "['#{@attr2_1.name}' = '#{@attr2_1.content}'] intersection ['year' = '2011']"
      items,count = @executor.do_query(@user.key, @domain.name, query)
      items.count.should == 1
      items[0].name.should == @item3.name
    end

    it "not set" do
      query = "not ['#{@attr2_1.name}' = '#{@attr2_1.content}']"
      items,count = @executor.do_query(@user.key, @domain.name, query)
      items.count.should == 1
      items[0].name.should == @item1.name
    end

    it "union" do
      query = "['year' = '2011'] union ['year' = '2010']"
      items,count = @executor.do_query(@user.key, @domain.name, query)
      items.count.should == 2
    end

  end

end
