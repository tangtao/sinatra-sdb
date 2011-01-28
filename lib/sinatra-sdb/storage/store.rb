module SDB
  module Storage
    class Store
        def initialize(storge)
          @storge = storge
          @query_executor = QueryExecutor.new
          @select_executor = SelectExecutor.new
        end
  
        def FindSecretByAccessKey(key)
          key = @storge.find_secret(key)
          raise Error::AuthMissingFailure.new if key.blank?
          key
        end
  
        def CreateDomain(args)
          raise Error::NumberDomainsExceeded.new if @storge.domains_count(args[:key]) > 100
          d = @storge.create_domain(args[:key], args[:domainName])
        end
  
        def DeleteDomain(args)
          @storge.delete_domain(args[:key], args[:domainName])
        end
  
        def ListDomains(args)
          size = args[:maxNumberOfDomains] || 100
          token = args[:nextToken] || 0
          domains = @storge.domain_name_list(args[:key])
          names = domains.sort[token, size]
          next_token = token+size if token+size < domains.count
          [names, next_token]
        end
  
        def DomainMetadata(args)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
          
          itemCount = d.items.size
          itemNamesSizeBytes = d.items.inject(0){|sum,item| sum + item.name.size}
          
          attributeNameCount = 0
          attributeNamesSizeBytes = 0
          d.items.each do |item|
            attr_set = Set.new(item.attrs.map{|a| a.name})
            attributeNameCount += attr_set.count
            attributeNamesSizeBytes += attr_set.inject(0){|sum,a| sum + a.size}
          end
          
          attributeValueCount = d.items.inject(0){|sum, item| sum + item.attrs.count}
          attributeValuesSizeBytes = d.items.inject(0) do |sum, item|
              sum + item.attrs.inject(0){|a_sum,a| a_sum + a.content.size}
          end
          
          r = {"ItemCount" => itemCount,
               "ItemNamesSizeBytes" => itemNamesSizeBytes,
               "AttributeNameCount" => attributeNameCount,
               "AttributeNamesSizeBytes" => attributeNamesSizeBytes,
               "AttributeValueCount" => attributeValueCount,
               "AttributeValuesSizeBytes" => attributeValuesSizeBytes,
               "Timestamp" => 1225486466
              }
        end
  
        def GetAttributes(args)
          raise Error::NoSuchDomain.new if @storge.find_domain_by_name(args[:key],args[:domainName]).blank?
          @storge.get_item_attrs(args[:key],args[:domainName],args[:itemName], args[:attributeNames])
        end
  
        def PutAttributes(args)
          raise Error::NoSuchDomain.new if @storge.find_domain_by_name(args[:key],args[:domainName]).blank?
          if @storge.verify_expected_value(args[:key], args[:domainName], args[:itemName], args[:expecteds])
            @storge.put_one_item_attrs(args[:key], args[:domainName], args[:itemName], args[:attributes])
          end
        end
  
        def BatchPutAttributes(args)
          raise Error::NoSuchDomain.new if @storge.find_domain_by_name(args[:key],args[:domainName]).blank?
          args[:items_attrs].each do |itemName, attributes|
            @storge.put_one_item_attrs(args[:key], args[:domainName], itemName, attributes)
          end
        end
        
        #TODO we need handle del item or attr name only
        def DeleteAttributes(args)#(key, domainName, itemName, attributes)
          raise Error::NoSuchDomain.new if @storge.find_domain_by_name(args[:key],args[:domainName]).blank?
          @storge.delete_one_item_attrs(args[:key], args[:domainName], args[:itemName], args[:attributes])
        end
  
        def Query(args)#(key, domainName, queryExpression)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
  
          items,count = @query_executor.do_query(args[:queryExpression], d)
          items.map{|i|i.name}
        end
  
        def QueryWithAttributes(args)#(key, domainName, queryExpression)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
          attr_names = args[:attributeNames]
  
          items,count = @query_executor.do_query(args[:queryExpression], d)
          result = []
          items.each do |item|
            result << [item.name, getAttributesByNames(item, attr_names)]
          end
          result
        end
  
        def Select(args)#(key, queryExpression)
          #u = findUserByAccessKey(args[:key])
          @select_executor.do_query(args[:selectExpression], args[:key])
        end
  
        
        private
        def findUserByAccessKey(key)
          User.find_by_key(key)
        end
  
        def getAttributesByNames(item, attr_names)
          result = []
          item.attrs.each do |a|
            if attr_names.include?(a.name)
              result << {:name => a.name, :value => a.content}
            end
          end
          result
        end
      
    end
  end
end
