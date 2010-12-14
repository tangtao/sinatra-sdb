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
  
  class SelectGrammar < Dhaka::Grammar
    for_symbol(Dhaka::START_SYMBOL_NAME) do
      start                %w| select_expression |
    end

    for_symbol('select_expression') do
      select_with_conditions %w| select output from domain conditions |
      select_without_conditions %w| select output from domain |
    end
    
    for_symbol('conditions') do
      only_where      %w| where predicates |
      with_where      %w| where predicates conditions2 |
      without_where   %w| conditions2 |
    end

    for_symbol('conditions2') do
      only_sort      %w| order by predicates2 |
      with_sort      %w| order by predicates2 conditions3 |
      without_sort   %w| conditions3 |
    end

    for_symbol('conditions3') do
      with_limit     %w| limit predicates3 |
    end

    for_symbol('output') do
      all_output          %w| * |
      item_name_output    %w| itemName |
      count_output        %w| count |
    end

    for_symbol('domain') do
      one_domain %w| identifier |
    end
  
    for_symbol('predicates') do
      single_predicate          %w| predicate |
      parenthetized_predicate   %w| ( predicates ) |
      not_predicates            %w| not predicates |
      intersection              %w| predicates intersection predicates |
      and_predicates            %w| predicates and predicates |
      or_predicates             %w| predicates or predicates |
    end

    for_symbol('predicates2') do
      order_by_name          %w| identifier |
    end

    for_symbol('predicates3') do
      limit_name          %w| identifier |
    end
    
    for_symbol('predicate') do
      single_comparison    %w| identifier comp_op constant |
    end
    
    for_symbol('comp_op') do
      equal                %w| = |
      greater_than         %w| > |
      less_than            %w| < |
      greater_or_equal     %w| >= |
      less_or_equal        %w| <= |
      not_equal            %w| != |
      starts_with          %w| starts-with |
    end
    
    for_symbol('identifier') do
      identifier           %w| quoted_string |
    end
    
    for_symbol('constant') do
      constant            %w| quoted_string |
    end
  
  end
  
  # The lexer for the query language.
  class SelectLexerSpec < Dhaka::LexerSpecification
    
    %w| = > < >= <= != starts-with |.each do |op|
      for_pattern(op) do
        create_token(op)
      end
    end
    
    for_pattern('\(') do
      create_token('(')
    end
    
    for_pattern('\)') do
      create_token(')')
    end

    for_pattern('\*') do
      create_token('*')
    end
    
    for_pattern('\s+') do
      # ignore whitespace
    end
    
    KEYWORDS = %w| select itemName count from where not and or intersection order by limit |
    KEYWORDS.each do |keyword|
      for_pattern(keyword) do
        create_token(keyword)
      end
    end
    
    for_pattern('[a-zA-Z0-9_]+') do
      create_token 'quoted_string'
    end
    
  end
  
  # The query evaluator. This class acts on the parse tree and will return
  # a list of item names that match the query from the evaluate method.
  class SelectEvaluator < Dhaka::Evaluator
    self.grammar = SelectGrammar
    
    def initialize(user)
      @user = user
      @domain = nil
      @sort_name = nil
    end
    
    define_evaluation_rules do
     
      for_select_without_conditions do
        output_type = evaluate(child_nodes[1])
        domain = evaluate(child_nodes[3])

        case output_type
        when :all
          domain.items
        when :itemName
          domain.items.map{|i| i.name}
        when :count
          domain.items.count
        end
      end

      for_select_with_conditions do
        output_type = evaluate(child_nodes[1])
        @domain = evaluate(child_nodes[3])
        items = evaluate(child_nodes[4])
        items = items.sort {|b,a| a.id <=> b.id}

        case output_type
        when :all
          items
        when :itemName
          items.map{|i| i.name}
        when :count
          items.count
        end
      end
      
      for_only_where do
        evaluate(child_nodes[1])
      end
      for_with_where do
        result = evaluate(child_nodes[1])
        evaluate(child_nodes[2])
        result
      end
      for_without_where do
        evaluate(child_nodes[0])
      end

      for_only_sort do
        @sort_name = evaluate(child_nodes[2])
      end
      for_with_sort do
        evaluate(child_nodes[1])
      end
      for_without_sort do
        evaluate(child_nodes[0])
      end
      
      for_with_limit do
        evaluate(child_nodes[1])
      end

      for_all_output {:all}
      for_item_name_output {:itemName}
      for_count_output {:count}

      for_one_domain do
        domain_name = evaluate(child_nodes[0])
        @user.domains.find_by_name(domain_name)
      end

      for_single_predicate do
        evaluate(child_nodes[0])
      end

      for_parenthetized_predicate do
        evaluate(child_nodes[1])
      end
      
      for_not_predicates do
        results = evaluate(child_nodes[1])
        @domain.items.to_set.difference(results)
      end
      
      for_intersection do
        results1 = evaluate(child_nodes[0])
        results2 = evaluate(child_nodes[2])
        results1.intersection(results2)
      end

      for_and_predicates do
        results1 = evaluate(child_nodes[0])
        results2 = evaluate(child_nodes[2])
        results1 & results2
      end

      for_or_predicates do
        results1 = evaluate(child_nodes[0])
        results2 = evaluate(child_nodes[2])
        results1 | results2
      end
      
      for_single_comparison do
        do_comparison(evaluate(child_nodes[0]), evaluate(child_nodes[1]), evaluate(child_nodes[2]))
      end
      
      for_equal { lambda { |v1, v2| v1 == v2 } }
      for_greater_than { lambda { |v1, v2| v1 > v2 } }
      for_less_than { lambda { |v1, v2| v1 < v2 } }
      for_greater_or_equal { lambda { |v1, v2| v1 >= v2 } }
      for_less_or_equal { lambda { |v1, v2| v1 <= v2 } }
      # TODO ['a1' != 'v2'] should return false if a1 has values v1 AND v2
      for_not_equal { lambda { |v1, v2| v1 != v2 } }
      for_starts_with { lambda { |v1, v2| v2[0...v1.length] == v1 } }
      
      for_identifier { val(child_nodes[0]) }
      for_constant { val(child_nodes[0]) }
    end
  
    def val(node)
      node.token.value
    end
  
    # Apply the given comparison params to every item in the domain
    def do_comparison(identifier, op, constant, negate = false)  
      results = Set.new
      
      if @domain
        @domain.items.each do |item|
          attrs = item.attrs.find_all_by_name(identifier)
          attrs.each do |attr|
            match = op.call(constant, attr.content)
            if (match && !negate) || (negate && !match)
              results << item
              break
            end
          end
        end
      end
      
      results
    end
  end
end