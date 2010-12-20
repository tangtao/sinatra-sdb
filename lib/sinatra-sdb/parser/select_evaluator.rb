require 'set'

module SDB
  
  class SelectEvaluator < Dhaka::Evaluator
    self.grammar = SelectGrammar
    
    def initialize(user)
      @user = user
      @domain = nil
      @sort_name = nil
      @sort_order = nil
      @limit_number = nil
      @explicit_attr_names = nil
    end
    
    define_evaluation_rules do
     
      for_select_without_conditions do
        output_type = evaluate(child_nodes[1])
        domain = evaluate(child_nodes[3])
        output_by_type(output_type, domain.items)
      end

      for_select_with_conditions do
        output_type = evaluate(child_nodes[1])
        @domain = evaluate(child_nodes[3])
        items = evaluate(child_nodes[4]).to_a
        
        if @sort_name.present?
          items = items.sort do |a, b|
            a1 = a.attrs.find_by_name(@sort_name)
            b1 = b.attrs.find_by_name(@sort_name)
            if @sort_order == :asc
              a1.content <=> b1.content
            else
              b1.content <=> a1.content
            end
          end
        end
        
        if @limit_number.present?
          items = items[0,@limit_number]
        end
        output_by_type(output_type, items)
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
        @sort_name,@sort_order = evaluate(child_nodes[2])
      end
      for_with_sort do
        @sort_name,@sort_order = evaluate(child_nodes[2])
        evaluate(child_nodes[3])
      end
      for_without_sort do
        evaluate(child_nodes[0])
      end
      
      for_order_by_name_only do
        [evaluate(child_nodes[0]), :asc]
      end
      for_order_by_name_asc do
        [evaluate(child_nodes[0]), :asc]
      end
      for_order_by_name_desc do
        [evaluate(child_nodes[0]), :desc]
      end
      
      
      for_with_limit do
        @limit_number = evaluate(child_nodes[1])
      end

      for_limit_number do
        evaluate(child_nodes[0]).to_i
      end

      for_all_output {:all}
      for_item_name_output {:itemName}
      for_count_output {:count}
      for_explicit_attr_output do
        @explicit_attr_names = evaluate(child_nodes[0])
        :explicit
      end
      
      for_one_attr_output do
        [ evaluate(child_nodes[0]) ]
      end

      for_attr_list_output do
        [ evaluate(child_nodes[0]) ] + evaluate(child_nodes[2])
      end

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
      for_constant { val(child_nodes[0])[1..-2] }
      for_number { val(child_nodes[0]) }
    end
  
    def val(node)
      node.token.value
    end
    def output_by_type(typ, items)
      case typ
      when :all,:explicit
        items.map { |i| [i.name, i.attrs_with_names(@explicit_attr_names)] }
      when :itemName
        items.map{|i| [i.name, []]}
      when :count
        [["Domain", [{:name => "Count", :value => "#{items.count}"}]]]
      end

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