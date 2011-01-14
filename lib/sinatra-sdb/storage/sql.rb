module SDB
  module Storage
    class SQL
        def initialize()
          @query_executor = QueryExecutor.new
          @select_executor = SelectExecutor.new
        end
  
        def FindSecretByAccessKey(key)
          u = User.find_by_key(key)
          raise Error::AuthMissingFailure.new if u.blank?
          u.secret
        end
  
        def CreateDomain(args)
          u = findUserByAccessKey(args[:key])
          raise Error::NumberDomainsExceeded.new if u.domains.count > 100
          d = Domain.find_or_create_by_user_id_and_name(u.id, args[:domainName])
        end
  
        def DeleteDomain(args)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
          d.destroy if d.present?
        end
  
        def ListDomains(args)
          u = findUserByAccessKey(args[:key])
          size = args[:maxNumberOfDomains] || 100
          token = args[:nextToken] || 0
          domains = u.domains
          names = domains.map{|x| x.name}.sort[token, size]
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
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
          raise Error::NoSuchDomain.new if d.blank?
          i = d.items.find_by_name(args[:itemName])
          return [] if i.blank?
          attr_names = args[:attributeNames]
          if attr_names.blank?
            i.attrs.map { |a| {:name => a.name, :value => a.content} }
          else
            getAttributesByNames(i, attr_names)
          end
        end
  
        def PutAttributes(args)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
          item = d.items.find_by_name(args[:itemName])
          Attr.transaction do
            item = Item.create(:name => args[:itemName], :domain => d) if item.blank?
            if verifyExpectedValue(item, args[:expecteds])
              updateItemAttrs(item, args[:attributes])
            end
          end
        end
  
        def BatchPutAttributes(args)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
          raise Error::NoSuchDomain.new if d.blank?
          Attr.transaction do
            args[:items_attrs].each do |i|
              itemName, attributes = i
              item = d.items.find_by_name(itemName)
              updateItemAttrs(item, attributes)
            end
          end
        end
        
        #TODO we need handle del item or attr name only
        def DeleteAttributes(args)#(key, domainName, itemName, attributes)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
          i = d.items.find_by_name(args[:itemName])
          Attr.transaction do
            if args[:attributes].blank?
              i.destroy
            else
              args[:attributes].each do |a|
                if a[:value].present?
                  a[:value].each do |x|
                    v = i.attrs.find_by_name_and_content(a[:name],x)
                    raise Error::AttributeDoesNotExist(a[:name]) if v.blank?
                    v.destroy
                  end
                else
                  Attr.destroy(i.attrs.find_all_by_name(a[:name]).map{|z| z.id})
                end
              end
              i.destroy if i.attrs.count == 0
            end
          end
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
          u = findUserByAccessKey(args[:key])
          @select_executor.do_query(args[:selectExpression], u)
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
  
        def updateItemAttrs(item, attributes)
          attributes.each do |a|
            if a[:replace]
              need_del_attrs = item.attrs.find_all_by_name(a[:name])
              Attr.destroy(need_del_attrs.map{|x|x.id})
            end
            a[:value].each { |v| Attr.create(:name => a[:name], :content => v, :item => item) }
          end
        end
  
        def verifyExpectedValue(item, expecteds)
          return true if expecteds.blank?
          expecteds.each do |e|
            attrs = item.attrs.find_all_by_name(e[:name])
            if e[:exists]
              return false if attrs.blank?
            else
              return false if attrs[0].content != e[:value]
            end
          end
          true
        end
      
    end
  end
end
