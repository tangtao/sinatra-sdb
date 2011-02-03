require 'set'

module SDB
  #from simplerdb
  # Uses the lexer/parser/evaluator to perform the query and do simple paging
  class QueryExecutor < BaseExecutor

    def initialize
      @lexer = Dhaka::Lexer.new(QueryLexerSpec)
      @parser = Dhaka::Parser.new(QueryGrammar)
    end
  
    # Execute the query
    def do_query(key, domain_name, query, max = 100, token = 0)
      parse_result = @parser.parse(@lexer.lex(query))
      token = 0 if token.nil?
      
      case parse_result
        when Dhaka::TokenizerErrorResult
          raise tokenize_error_message(parse_result.unexpected_char_index, query)
        when Dhaka::ParseErrorResult
          raise parse_error_message(parse_result.unexpected_token, query) 
      end
  
      items = QueryEvaluator.new(key,domain_name).evaluate(parse_result)
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
  
  # The SimpleDB query language grammar, as defined at
  # http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_Query.html
  class QueryGrammar < Dhaka::Grammar
    for_symbol(Dhaka::START_SYMBOL_NAME) do
      start                %w| predicates |
    end
  
    for_symbol('predicates') do
      single_predicate     %w| predicate |
      not_predicate        %w| not predicate |
      intersection         %w| predicate intersection predicates |
      not_intersection     %w| not predicate intersection predicates |
      union                %w| predicate union predicates |
      not_union            %w| not predicate union predicates |
    end
    
    for_symbol('predicate') do
      attribute_comparison %w| [ attribute_comparison ] |
    end
    
    for_symbol('attribute_comparison') do
      single_comparison    %w| identifier comp_op constant |
      and_comparison       %w| identifier comp_op constant and attribute_comparison |
      or_comparison        %w| identifier comp_op constant or attribute_comparison |
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
  class QueryLexerSpec < Dhaka::LexerSpecification
    
    %w| = > < >= <= != starts-with |.each do |op|
      for_pattern(op) do
        create_token(op)
      end
    end
    
    for_pattern('\[') do
      create_token('[')
    end
    
    for_pattern('\]') do
      create_token(']')
    end
    
    for_pattern('\s+') do
      # ignore whitespace
    end
    
    KEYWORDS = %w| not and or union intersection |
    KEYWORDS.each do |keyword|
      for_pattern(keyword) do
        create_token(keyword)
      end
    end
    
    for_pattern("'(\\\\'|[^'])+'") do
      create_token 'quoted_string'
    end
    
  end
  
  # The query evaluator. This class acts on the parse tree and will return
  # a list of item names that match the query from the evaluate method.
  class QueryEvaluator < Dhaka::Evaluator
    self.grammar = QueryGrammar
    
    def initialize(key,domain_name)
      @storage = Storage::SelectDefault.new(key)
      @storage.domain = domain_name
      user = User.by_key(key)
      @domain = Domain.by_name(user, domain_name)
    end
    
    define_evaluation_rules do
     
      for_single_predicate do
        evaluate(child_nodes[0])
      end
      
      for_not_predicate do
        results = evaluate(child_nodes[1])
        all_items.difference(results)
      end
      
      for_intersection do
        results = evaluate(child_nodes[0])
        results.intersection(evaluate(child_nodes[2]))
      end
      
      # TODO Nots are probably not handled correctly. Need to play with AWS to find out for sure.
      for_not_intersection do
        results = evaluate(child_nodes[1])
        all_items.difference(results.intersection(evaluate(child_nodes[3])))
      end
      
      for_union do
        results = evaluate(child_nodes[0])
        results.union(evaluate(child_nodes[2]))
      end
      
      for_not_union do
        results = evaluate(child_nodes[1])
        all_items.difference(results.union(evaluate(child_nodes[3])))
      end
      
      for_attribute_comparison do
        evaluate(child_nodes[1])
      end
      
      for_single_comparison do
        do_comparison(evaluate(child_nodes[0]), evaluate(child_nodes[1]), evaluate(child_nodes[2]))
      end
      
      for_and_comparison do
        results = do_comparison(evaluate(child_nodes[0]), evaluate(child_nodes[1]), evaluate(child_nodes[2]))
        results.intersection(evaluate(child_nodes[4]))
      end
      
      for_or_comparison do
        results = do_comparison(evaluate(child_nodes[0]), evaluate(child_nodes[1]), evaluate(child_nodes[2]))
        results.union(evaluate(child_nodes[4]))
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
      node.token.value.to_s[1..-2]
    end
  
    def all_items
      @storage.all_items.to_set
    end
  
    # Apply the given comparison params to every item in the domain
    def do_comparison(identifier, op, constant)
      results = Set.new
      
      all_items.each do |item|
        attrs = @storage.find_all_attr_by_name(item, identifier)
        attrs.each do |attr|
          match = op.call(constant, attr.content)
          if match
            results << item
            break
          end
        end
      end
      results
    end
  end
end