module SDB
  
  class SelectGrammar < Dhaka::Grammar
    for_symbol(Dhaka::START_SYMBOL_NAME) do
      start                %w| select_expression |
    end

    for_symbol('select_expression') do
      select_with_conditions %w| select output from domain where_begin_conditions |
      select_without_conditions %w| select output from domain |
    end
    
    for_symbol('where_begin_conditions') do
      only_where      %w| where predicates |
      with_where      %w| where predicates sort_begin_conditions |
      without_where   %w| sort_begin_conditions |
    end

    for_symbol('sort_begin_conditions') do
      only_sort      %w| order by sort_predicates |
      with_sort      %w| order by sort_predicates limit_begin_conditions |
      without_sort   %w| limit_begin_conditions |
    end

    for_symbol('limit_begin_conditions') do
      with_limit     %w| limit limit_predicates |
    end

    for_symbol('output') do
      all_output              %w| * |
      item_name_output        %w| itemName ( ) |
      count_output            %w| count ( * ) |
      explicit_attr_output    %w| attr_list |
    end

    for_symbol('attr_list') do
      one_attr_output    %w| identifier |
      attr_list_output   %w| identifier , attr_list |
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

    for_symbol('sort_predicates') do
      order_by_name_only        %w| identifier |
      order_by_name_asc         %w| identifier asc |
      order_by_name_desc        %w| identifier desc |
    end

    for_symbol('limit_predicates') do
      limit_number          %w| number |
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
      identifier           %w| identifier_string |
    end
    
    for_symbol('constant') do
      constant            %w| quoted_string |
    end

    for_symbol('number') do
      number            %w| number_string |
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

    for_pattern(',') do
      create_token(',')
    end
  
    for_pattern('\s+') do
      # ignore whitespace
    end
    
    KEYWORDS = %w| select itemName count from where not and or intersection order by asc desc limit |
    KEYWORDS.each do |keyword|
      for_pattern(keyword) do
        create_token(keyword)
      end
    end

    for_pattern("'(\\\\'|[^'])+'") do
      create_token 'quoted_string'
    end
    
    for_pattern('[a-zA-Z][a-zA-Z0-9_]*') do
      create_token 'identifier_string'
    end

    for_pattern('[0-9]+') do
      create_token 'number_string'
    end
    
  end

end