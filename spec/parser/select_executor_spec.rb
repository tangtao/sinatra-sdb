require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

  

describe "Select Executor Test" do

  before(:all) do
    dbclean()
    @selexecutor = SDB::SelectExecutor.new
    @items,@attrs = db.createQueryItems
  end

  describe "Output" do
    it "all" do
      query = "select * from #{db.domain.name}"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 3
      result.map{|i| i[0]}.should include(@items[0].name,@items[1].name,@items[2].name)
    end

    it "item name" do
      query = "select itemName() from #{db.domain.name}"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 3
      result.map{|i| i[0]}.should include(@items[0].name,@items[1].name,@items[2].name)
    end

    it "count" do
      query = "select count(*) from #{db.domain.name}"
      result = @selexecutor.do_query(query, db.user.key)
      result[0][1][0][:value].to_i.should == 3
    end

    it "explicit list of attributes" do
      query = "select #{@attrs[1][:a1].name},#{@attrs[1][:a2].name} from #{db.domain.name}"
      attrs = Set.new
      attrs << @attrs[1][:a1].name
      attrs << @attrs[1][:a2].name
      
      result = @selexecutor.do_query(query, db.user.key)
      rattrs = Set.new
      result.each do |item|
        item[1].each {|a| rattrs << a[:name]}
      end
      rattrs.should == attrs
    end


  end

  describe "Simple Predicate" do
    it "one attr" do
      query = "select * from #{db.domain.name} where (#{@attrs[0][:a1].name} = '#{@attrs[0][:a1].content}')"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 1
      result[0] == @items[0].name
    end

    it "itemName()" do
      query = "select * from #{db.domain.name} where itemName() = '#{@items[2].name}' "
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 1
      result[0] == @items[2].name
    end

    it "in with attr" do
      query = "select * from #{db.domain.name} where #{@attrs[1][:a1].name} in ( '#{@attrs[1][:a1].content}', 'xxxxxx' )"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 2
    end

    it "in with itemName()" do
      query = "select * from #{db.domain.name} where itemName( ) in ( '#{@items[0].name}', '#{@items[1].name}' )"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 2
    end

    it "between with attr" do
      query = "select * from #{db.domain.name} where year between '2009' and '2010' "
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 2
    end

    it "is null with attr" do
      query = "select * from #{db.domain.name} where #{@attrs[1][:a1].name} is null"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 1
    end

    it "is not null with attr" do
      query = "select * from #{db.domain.name} where #{@attrs[1][:a1].name} is not null"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 2
    end

    it "like" do
      query = "select * from #{db.domain.name} where year like '200%'"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 1
    end

    it "not like" do
      query = "select * from #{db.domain.name} where year not like '200%'"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 2
    end

    it "every()" do
      query = "select * from #{db.domain.name} where every(#{@attrs[2][:a3].name}) = '#{@attrs[2][:a3].content}'"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 1
      result[0] == @items[2].name
    end

  end

  describe "Composite Predicates" do

    it "AND expr" do
      query = "select * from #{db.domain.name} where (#{@attrs[1][:a1].name} = " +
              "'#{@attrs[1][:a1].content}') and (#{@attrs[1][:a2].name} = '#{@attrs[1][:a2].content}')"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 1
    end

    it "OR expr" do
      query = "select * from #{db.domain.name} where (#{@attrs[0][:a1].name} = " +
              "'#{@attrs[0][:a1].content}') or (#{@attrs[1][:a1].name} = '#{@attrs[1][:a1].content}')"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 3
    end

    it "NOT expr" do
      query = "select * from #{db.domain.name} where not (#{@attrs[0][:a1].name} = '#{@attrs[0][:a1].content}')"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 2
    end

  end

  describe "Intersection Predicate" do

    it "No.1" do
      query = "select * from #{db.domain.name} where (#{@attrs[1][:a1].name} = " +
              "'#{@attrs[1][:a1].content}') intersection (#{@attrs[2][:a2].name} = '#{@attrs[2][:a2].content}')"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 1
    end

  end

  describe "Sort and Limit Condition" do


    it "Simple Sort" do
      query = "select * from #{db.domain.name} where #{@attrs[1][:a1].name} = " + 
              "'#{@attrs[1][:a1].content}' order by #{@attrs[1][:a1].name} "
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 2
      attr0 = result[0][1].find{|i| i[:name] == @attrs[1][:a1].name}
      attr1 = result[1][1].find{|i| i[:name] == @attrs[1][:a1].name}
      attr0[:value].should <= attr1[:value]
    end

    it "Simple Sort Desc" do
      query = "select * from #{db.domain.name} where #{@attrs[1][:a1].name} = " + 
              "'#{@attrs[1][:a1].content}' order by #{@attrs[1][:a1].name} desc"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 2
      attr0 = result[0][1].find{|i| i[:name] == @attrs[1][:a1].name}
      attr1 = result[1][1].find{|i| i[:name] == @attrs[1][:a1].name}
      attr0[:value].should >= attr1[:value]
    end

    it "Simple Limit Only" do
      query = "select * from #{db.domain.name} where #{@attrs[1][:a1].name} = '#{@attrs[1][:a1].content}' limit 1"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 1
    end

    it "Simple Sort and Limit" do
      query = "select * from #{db.domain.name} where #{@attrs[1][:a1].name} = '#{@attrs[1][:a1].content}' " + 
              "order by #{@attrs[1][:a1].name} limit 1"
      result = @selexecutor.do_query(query, db.user.key)
      result.count.should == 1
    end
  end
end
