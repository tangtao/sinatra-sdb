require 'set'

module SDB
  # Uses the lexer/parser/evaluator to perform the query and do simple paging
  class SelectExecutor < BaseExecutor
  
    def initialize
      logger           = Logger.new(STDOUT)
      logger.level     = Logger::ERROR
      @lexer = Dhaka::Lexer.new(SelectLexerSpec)
      @parser = Dhaka::Parser.new(SelectGrammar, logger)
    end
    
    # Execute the query
    def do_query(query, key, max = 100, token = 0)
      parse_result = @parser.parse(@lexer.lex(query))
      token = 0 if token.nil?
      
      case parse_result
        when Dhaka::TokenizerErrorResult
          raise tokenize_error_message(parse_result.unexpected_char_index, query)
        when Dhaka::ParseErrorResult
          raise parse_error_message(parse_result.unexpected_token, query) 
      end
  
      items = SelectEvaluator.new(key).evaluate(parse_result)
      return items
      
      ########################
      results = []
      count = 0
      items.each do |item|
        break if results.size == max
        results << item if count >= token
        count += 1
      end
      
      if (count == items.size)
        return results,nil
      else
        return results,count
      end
    end
  
  end

end