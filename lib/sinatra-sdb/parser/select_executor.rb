require 'set'

module SDB
  # Uses the lexer/parser/evaluator to perform the query and do simple paging
  class SelectExecutor
    ERROR_MARKER = ">>>"
  
    def initialize
      logger           = Logger.new(STDOUT)
      logger.level     = Logger::ERROR
      @lexer = Dhaka::Lexer.new(SelectLexerSpec)
      @parser = Dhaka::Parser.new(SelectGrammar, logger)
    end
    
    # Execute the query
    def do_query(query, user, max = 100, token = 0)
      parse_result = @parser.parse(@lexer.lex(query))
      token = 0 if token.nil?
      
      case parse_result
        when Dhaka::TokenizerErrorResult
          raise tokenize_error_message(parse_result.unexpected_char_index, query)
        when Dhaka::ParseErrorResult
          raise parse_error_message(parse_result.unexpected_token, query) 
      end
  
      items = SelectEvaluator.new(user).evaluate(parse_result)
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
    
    # From dhaka examples
    def parse_error_message(unexpected_token, program)
      if unexpected_token.symbol_name == Dhaka::END_SYMBOL_NAME
        "Unexpected end of file."
      else
        "Unexpected token #{unexpected_token.symbol_name}:\n#{program.dup.insert(unexpected_token.input_position - 1, ERROR_MARKER)}"
      end
    end
    
    def tokenize_error_message(unexpected_char_index, program)
      "Unexpected character #{program[unexpected_char_index - 1].chr}:\n#{program.dup.insert(unexpected_char_index - 1, ERROR_MARKER)}"
    end
    
    def evaluation_error_message(evaluation_result, program)
      "#{evaluation_result.exception}:\n#{program.dup.insert(evaluation_result.node.tokens[0].input_position, ERROR_MARKER)}"
    end
  
  end

end