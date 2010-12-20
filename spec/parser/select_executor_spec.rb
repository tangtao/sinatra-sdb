require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

  

describe "Select Executor Test" do

  before(:all) do
    dbclean()
    @selexecutor = SDB::SelectExecutor.new
    
    @attr1_1 = Attr.make!
    @item1 = @attr1_1.item
    @domain = @item1.domain
    @user = @domain.user

    @item2 = Item.make!(:domain => @domain)
    @attr2_1 = Attr.make!(:item => @item2)
    @attr2_2 = Attr.make!(:item => @item2)
    
    @item3 = Item.make!(:domain => @domain)
    @attr3_1 = Attr.make!(:item => @item3, :name => @attr2_1.name, :content => @attr2_1.content)
    @attr3_2 = Attr.make!(:item => @item3)
  end

  describe "Output" do
    it "all" do
      query = "select * from #{@domain.name}"
      result = @selexecutor.do_query(query, @user)
      result.count.should == 3
      result[0][0].should == @item1.name
    end

    it "item name" do
      query = "select itemName() from #{@domain.name}"
      result = @selexecutor.do_query(query, @user)
      result.count.should == 3
      result[0] == @item1.name
    end

    it "count" do
      query = "select count(*) from #{@domain.name}"
      result = @selexecutor.do_query(query, @user)
      result[0][1][0][:value].to_i.should == 3
    end

    it "explicit list of attributes" do
      query = "select #{@attr2_1.name},#{@attr2_2.name} from #{@domain.name}"
      attrs = Set.new
      attrs << @attr2_1.name
      attrs << @attr2_2.name
      
      result = @selexecutor.do_query(query, @user)
      rattrs = Set.new
      result.each do |item|
        item[1].each {|a| rattrs << a[:name]}
      end
      rattrs.should == attrs
    end


  end

  describe "Simple Predicate" do
    it "one attr" do
      query = "select * from #{@domain.name} where (#{@attr1_1.name} = '#{@attr1_1.content}')"
      result = @selexecutor.do_query(query, @user)
      result.count.should == 1
    end

  end

  describe "Composite Predicates" do

    it "AND expr" do
      query = "select * from #{@domain.name} where (#{@attr2_1.name} = " +
              "'#{@attr2_1.content}') and (#{@attr2_2.name} = '#{@attr2_2.content}')"
      result = @selexecutor.do_query(query, @user)
      result.count.should == 1
    end

    it "OR expr" do
      query = "select * from #{@domain.name} where (#{@attr1_1.name} = " +
              "'#{@attr1_1.content}') or (#{@attr2_1.name} = '#{@attr2_1.content}')"
      result = @selexecutor.do_query(query, @user)
      result.count.should == 3
    end

    it "NOT expr" do
      query = "select * from #{@domain.name} where not (#{@attr1_1.name} = '#{@attr1_1.content}')"
      result = @selexecutor.do_query(query, @user)
      result.count.should == 2
    end

  end

  describe "Intersection Predicate" do

    it "No.1" do
      query = "select * from #{@domain.name} where (#{@attr2_1.name} = " +
              "'#{@attr2_1.content}') intersection (#{@attr3_2.name} = '#{@attr3_2.content}')"
      result = @selexecutor.do_query(query, @user).to_a
      result.count.should == 1
    end

  end

  describe "Sort and Limit Condition" do


    it "Simple Sort" do
      query = "select * from #{@domain.name} where #{@attr2_1.name} = '#{@attr2_1.content}' order by #{@attr2_1.name} "
      result = @selexecutor.do_query(query, @user)
      result.count.should == 2
      attr0 = result[0][1].find{|i| i[:name] == @attr2_1.name}
      attr1 = result[1][1].find{|i| i[:name] == @attr2_1.name}
      attr0[:value].should <= attr1[:value]
    end

    it "Simple Sort Desc" do
      query = "select * from #{@domain.name} where #{@attr2_1.name} = '#{@attr2_1.content}' order by #{@attr2_1.name} desc"
      result = @selexecutor.do_query(query, @user)
      result.count.should == 2
      attr0 = result[0][1].find{|i| i[:name] == @attr2_1.name}
      attr1 = result[1][1].find{|i| i[:name] == @attr2_1.name}
      attr0[:value].should >= attr1[:value]
    end

    it "Simple Limit Only" do
      query = "select * from #{@domain.name} where #{@attr2_1.name} = '#{@attr2_1.content}' limit 1"
      result = @selexecutor.do_query(query, @user)
      result.count.should == 1
    end

    it "Simple Sort and Limit" do
      query = "select * from #{@domain.name} where #{@attr2_1.name} = '#{@attr2_1.content}' order by #{@attr2_1.name} limit 1"
      result = @selexecutor.do_query(query, @user)
      result.count.should == 1
    end
  end
end
