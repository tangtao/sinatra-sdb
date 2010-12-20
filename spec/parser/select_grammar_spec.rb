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
  
  def checkSQLparser(query_string)
    parse_result = @parser.parse(@lexer.lex(query_string))
    if parse_result.class != Dhaka::ParseSuccessResult
      pp parse_result
    end
    parse_result.class.should == Dhaka::ParseSuccessResult
  end

end