require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Select Parser Test" do
  
  
  describe "SelectGrammar" do
    before(:each) do
      @lexer = Dhaka::Lexer.new(SDB::SelectLexerSpec)
      @parser = Dhaka::Parser.new(SDB::SelectGrammar)
    end
    
    it "Simple query" do
      query = "select * from bookmark_0001 where (attr = v_0001)"
      parse_result = @parser.parse(@lexer.lex(query))
      pp parse_result
    end

  end

  describe "SelectExecutor" do
    before(:each) do
      @selexecutor = SDB::SelectExecutor.new
      @attr1 = Attr.make!
      @item = @attr1.item
      @domain = @item.domain
      @user = @domain.user
    end
    describe "Output" do
      it "all" do
        query = "select * from #{@domain.name}"
        result = @selexecutor.do_query(query, @user)
        result.count.should == 1
        result[0].name.should == @item.name
      end
  
      it "item name" do
        query = "select itemName from #{@domain.name}"
        result = @selexecutor.do_query(query, @user)
        result.count.should == 1
        result[0] == @item.name
      end
  
      it "count" do
        query = "select count from #{@domain.name}"
        result = @selexecutor.do_query(query, @user)
        result.should == 1
      end
    end

    describe "Simple Conditions" do
      it "one item, one attr" do
        query = "select * from #{@domain.name} where (#{@attr1.name} = #{@attr1.content})"
        result = @selexecutor.do_query(query, @user)
        result.count.should == 1
      end

      it "two item, one attr" do
        item2 = Item.make!(:domain => @domain)
        attr2 = Attr.make!(:item => item2)
        query = "select * from #{@domain.name} where (#{attr2.name} = #{attr2.content})"
        result = @selexecutor.do_query(query, @user).to_a
        result.count.should == 1
        result[0].name.should == item2.name
      end
  
    end


  end


end
