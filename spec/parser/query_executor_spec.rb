require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Query Executor Test" do

  before(:all) do
    dbclean()
    @items,@attrs = db.createQueryItems
    @executor = SDB::QueryExecutor.new
  end

  describe "Simple Predicate" do
    describe "Simple attr" do
      it "one attr" do
        query = "['#{@attrs[0][:a1].name}' = '#{@attrs[0][:a1].content}']"
        items,count = @executor.do_query(db.user.key, db.domain.name, query)
        count.should be_nil
        items[0].name.should == @items[0].name
      end
    end

    describe "Attribute comparison" do
      it "and" do
        query = "['#{@attrs[1][:a1].name}' = '#{@attrs[1][:a1].content}' and 'year' = '2011']"
        items,count = @executor.do_query(db.user.key, db.domain.name, query)
        items.count.should == 1
        items[0].name.should == @items[2].name
      end

      it "or" do
        query = "['#{@attrs[1][:a1].name}' = '#{@attrs[1][:a1].content}' or 'year' = '2011']"
        items,count = @executor.do_query(db.user.key, db.domain.name, query)
        items.count.should == 2
      end

    end

  end

  describe "multiple predicates" do

    it "intersection" do
      query = "['#{@attrs[1][:a1].name}' = '#{@attrs[1][:a1].content}'] intersection ['year' = '2011']"
      items,count = @executor.do_query(db.user.key, db.domain.name, query)
      items.count.should == 1
      items[0].name.should == @items[2].name
    end

    it "not set" do
      query = "not ['#{@attrs[1][:a1].name}' = '#{@attrs[1][:a1].content}']"
      items,count = @executor.do_query(db.user.key, db.domain.name, query)
      items.count.should == 1
      items[0].name.should == @items[0].name
    end

    it "union" do
      query = "['year' = '2011'] union ['year' = '2010']"
      items,count = @executor.do_query(db.user.key, db.domain.name, query)
      items.count.should == 2
    end

  end

end
