#
# extend RightAws and make link only.
#

module RightAws

  class SdbInterface
    

    def list_domains_link(max_number_of_domains = nil, next_token = nil )
      request_params = { 'MaxNumberOfDomains' => max_number_of_domains,
                         'NextToken'          => next_token }
      link = generate_request("ListDomains", request_params)
      link[:request].path
    end
    
    def create_domain_link(domain_name)
      link = generate_request("CreateDomain",
                              'DomainName' => domain_name)
      link[:request].path
    end

    def delete_domain_link(domain_name)
      link = generate_request("DeleteDomain",
                              'DomainName' => domain_name)
      link[:request].path
    end

    def domain_metadata_link(domain_name)
      link = generate_request("DomainMetadata",
                              'DomainName' => domain_name)
      link[:request].path
    end
    
    def put_attributes_link(domain_name, item_name, attributes, replace = false)
      params = { 'DomainName' => domain_name,
                 'ItemName'   => item_name }.merge(pack_attributes(attributes, replace))
      link = generate_request("PutAttributes", params)
      link[:request].path
    end
    def put_attributes_link_new(domain_name, item_name, attributes, expecteds=nil, replace = false)
      params = { 'DomainName' => domain_name,
                 'ItemName'   => item_name }.merge(pack_attributes(attributes, replace)).
                 														 merge(pack_expecteds(expecteds))
      link = generate_request("PutAttributes", params)
      link[:request].path
    end

    def batch_put_attributes_link(domain_name, items, replace = false)
      params = { 'DomainName' => domain_name }.merge(pack_attributes(items, replace, true))
      link = generate_request("BatchPutAttributes", params)
      link[:request].path
    end
    
    def get_attributes_link(domain_name, item_name, attribute_names=nil)
      attribute_names = Array(attribute_names)
      
      request_params = { 'DomainName'       => domain_name,
                         'ItemName'         => item_name}
                         
      attribute_names.each_with_index do |attribute, idx|
        request_params["AttributeName.#{idx+1}"] = attribute
      end

      link = generate_request("GetAttributes", request_params )
      link[:request].path
    end

    def delete_attributes_link(domain_name, item_name, attributes = nil)
      params = { 'DomainName' => domain_name,
                 'ItemName'   => item_name }.merge(pack_attributes(attributes))
      link = generate_request("DeleteAttributes", params)
      link[:request].path
    end
    
    
    def query_link(domain_name, query_expression = nil, max_number_of_items = nil, next_token = nil)
      query_expression = query_expression_from_array(query_expression) if query_expression.is_a?(Array)
      @last_query_expression = query_expression
      #
      request_params = { 'DomainName'       => domain_name,
                         'QueryExpression'  => query_expression,
                         'MaxNumberOfItems' => max_number_of_items,
                         'NextToken'        => next_token }
      link = generate_request("Query", request_params)
      link[:request].path
    end
    
    def query_with_attributes_link(domain_name, attributes=[], query_expression = nil, max_number_of_items = nil, next_token = nil)
      attributes = Array(attributes)
      query_expression = query_expression_from_array(query_expression) if query_expression.is_a?(Array)
      @last_query_expression = query_expression
      #
      request_params = { 'DomainName'       => domain_name,
                         'QueryExpression'  => query_expression,
                         'MaxNumberOfItems' => max_number_of_items,
                         'NextToken'        => next_token }
      attributes.each_with_index do |attribute, idx|
        request_params["AttributeName.#{idx+1}"] = attribute
      end
      link = generate_request("QueryWithAttributes", request_params)
      link[:request].path
    end

    def select_link(select_expression, next_token = nil)
      select_expression      = query_expression_from_array(select_expression) if select_expression.is_a?(Array)
      @last_query_expression = select_expression
      #
      request_params = { 'SelectExpression' => select_expression,
                         'NextToken'        => next_token }
      link = generate_request("Select", request_params)
      link[:request].path
    end


    def pack_expecteds(expecteds)
      result = {}
      if expecteds
        idx = 0
        expecteds.each do |name, values|
          # pack Name/Value
          unless values.nil?
            # Array(values) does not work here:
            #  - Array('') => [] but we wanna get here ['']
            [values].flatten.each do |value|
              result["Expected.#{idx}.Name"]  = name
              result["Expected.#{idx}.Value"] = ruby_to_sdb(value)
              idx += 1
            end
          else
            result["Expected.#{idx}.Name"] = name
            result["Expected.#{idx}.Value"] = ruby_to_sdb(nil)
            idx += 1
          end
        end
      end
      result
    end
  end
  
end
