require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Select Parser Test" do
  
  
  describe "SelectGrammar" do
    before(:each) do
      logger           = Logger.new(STDOUT)
      logger.level     = Logger::ERROR

      @lexer = Dhaka::Lexer.new(SDB::SelectLexerSpec)
      @parser = Dhaka::Parser.new(SDB::SelectGrammar, logger)
    end
    
    it "query with simple where" do
      checkSQLparser("select * from book where a = 'v1'")
    end
    it "query with logic where" do
      checkSQLparser("select * from book where (a1 = 'v1' or a3 = 'v3') and (a2 = 'v2' or a4 = 'v4')")
    end
    it "query with sort" do
      checkSQLparser("select * from bookmark_0001 order by xxx limit 1")
      checkSQLparser("select * from bookmark_0001 order by xxx")
    end

    it "query with limit" do
      checkSQLparser("select * from bookmark_0001 order by xxx limit 100")
      checkSQLparser("select * from bookmark_0001 limit 100")
    end
    
    def checkSQLparser(query_string)
      parse_result = @parser.parse(@lexer.lex(query_string))
      if parse_result.class != Dhaka::ParseSuccessResult
        pp parse_result
      end
      parse_result.class.should == Dhaka::ParseSuccessResult
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
        query = "select itemName() from #{@domain.name}"
        result = @selexecutor.do_query(query, @user)
        result.count.should == 1
        result[0] == @item.name
      end
  
      it "count" do
        query = "select count(*) from #{@domain.name}"
        result = @selexecutor.do_query(query, @user)
        result.should == 1
      end
    end

    describe "Simple Predicate" do
      it "one item, one attr" do
        query = "select * from #{@domain.name} where (#{@attr1.name} = '#{@attr1.content}')"
        result = @selexecutor.do_query(query, @user)
        result.count.should == 1
      end

      it "two item, one attr" do
        item2 = Item.make!(:domain => @domain)
        attr2 = Attr.make!(:item => item2)
        query = "select * from #{@domain.name} where (#{attr2.name} = '#{attr2.content}')"
        result = @selexecutor.do_query(query, @user).to_a
        result.count.should == 1
        result[0].name.should == item2.name
      end
  
    end

    describe "Composite Predicates" do
      before(:each) do
        @item2 = Item.make!(:domain => @domain)
        @attr2 = Attr.make!(:item => @item2)
      end

      it "AND expr" do
        query = "select * from #{@domain.name} where (#{@attr1.name} = " +
                "'#{@attr1.content}') and (#{@attr2.name} = '#{@attr2.content}')"
        result = @selexecutor.do_query(query, @user).to_a
        result.count.should == 0
      end

      it "OR expr" do
        query = "select * from #{@domain.name} where (#{@attr1.name} = " +
                "'#{@attr1.content}') or (#{@attr2.name} = '#{@attr2.content}')"
        result = @selexecutor.do_query(query, @user).to_a
        result.count.should == 2
      end

      it "NOT expr" do
        query = "select * from #{@domain.name} where not (#{@attr1.name} = '#{@attr1.content}')"
        result = @selexecutor.do_query(query, @user).to_a
        result.count.should == 1
        result[0].name.should == @item2.name
      end
  
    end

    describe "Intersection Predicate" do
      before(:each) do
        @item2 = Item.make!(:domain => @domain)
        @attr2_1 = Attr.make!(:item => @item2)
        @attr2_2 = Attr.make!(:item => @item2)
        
        @item3 = Item.make!(:domain => @domain)
        @attr3_1 = Attr.make!(:item => @item3, :name => @attr2_1.name, :content => @attr2_1.content)
        @attr3_2 = Attr.make!(:item => @item3)
      end


      it "No.1" do
        query = "select * from #{@domain.name} where (#{@attr2_1.name} = " +
                "'#{@attr2_1.content}') intersection (#{@attr3_2.name} = '#{@attr3_2.content}')"
        result = @selexecutor.do_query(query, @user).to_a
        result.count.should == 1
      end
  
    end

    describe "Sort and Limit Condition" do
      before(:each) do
        @item2 = Item.make!(:domain => @domain)
        @attr2_1 = Attr.make!(:item => @item2)
        @attr2_2 = Attr.make!(:item => @item2)
        
        @item3 = Item.make!(:domain => @domain)
        @attr3_1 = Attr.make!(:item => @item3, :name => @attr2_1.name, :content => @attr2_1.content)
        @attr3_2 = Attr.make!(:item => @item3)
      end


      it "Simple Sort" do
        query = "select * from #{@domain.name} where #{@attr2_1.name} = '#{@attr2_1.content}' order by #{@attr2_1.name} "
        result = @selexecutor.do_query(query, @user)
        result.count.should == 2
        attr0 = result[0].attrs.find_by_name(@attr2_1.name).content
        attr1 = result[1].attrs.find_by_name(@attr2_1.name).content
        attr0.should <= attr1
      end
  
      it "Simple Sort Desc" do
        query = "select * from #{@domain.name} where #{@attr2_1.name} = '#{@attr2_1.content}' order by #{@attr2_1.name} desc"
        result = @selexecutor.do_query(query, @user)
        result.count.should == 2
        attr0 = result[0].attrs.find_by_name(@attr2_1.name).content
        attr1 = result[1].attrs.find_by_name(@attr2_1.name).content
        attr0.should >= attr1
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


end
