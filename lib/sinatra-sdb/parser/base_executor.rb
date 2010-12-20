module SDB
  # Uses the lexer/parser/evaluator to perform the query and do simple paging
  class BaseExecutor
    ERROR_MARKER = ">>>"
  
    
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