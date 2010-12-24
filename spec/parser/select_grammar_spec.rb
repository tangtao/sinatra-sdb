require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Select Grammar Test" do
  
  before(:all) do
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

  it "output with explicit list of attributes" do
    checkSQLparser("select attr_0001 from bookmark_0001")
    checkSQLparser("select attr_0001,attr_002,attr_03 from bookmark_0001")
  end

  it "itemName() predicate" do
    checkSQLparser("select attr_0001 from bookmark_0001 where itemName() = 'v1'")
  end

  it "every() predicate" do
    checkSQLparser("select attr_0001 from bookmark_0001 where every(attr_001) = 'v1'")
  end

  it "like predicate" do
    checkSQLparser("select attr_0001 from bookmark_0001 where attr_001 like 'v1'")
    checkSQLparser("select attr_0001 from bookmark_0001 where itemName() like 'v1'")
  end

  it "not like predicate" do
    checkSQLparser("select attr_0001 from bookmark_0001 where attr_001 not like 'v1'")
  end

  it "is null predicate" do
    checkSQLparser("select attr_0001 from bookmark_0001 where attr_001 is null")
  end
  
  it "is not null predicate" do
    checkSQLparser("select attr_0001 from bookmark_0001 where attr_001 is not null")
  end

  it "between predicate" do
    checkSQLparser("select attr_0001 from bookmark_0001 where attr_001 between '100' and '200'")
    checkSQLparser("select attr_0001 from bookmark_0001 where itemName() between '100' and '200'")
  end

  it "in predicate" do
    checkSQLparser("select attr_0001 from bookmark_0001 where attr_001 in ('100','200')")
    checkSQLparser("select attr_0001 from bookmark_0001 where itemName() in ('100','200')")
  end

  def checkSQLparser(query_string)
    parse_result = @parser.parse(@lexer.lex(query_string))
    if parse_result.class != Dhaka::ParseSuccessResult
      pp parse_result
    end
    parse_result.class.should == Dhaka::ParseSuccessResult
  end

end
