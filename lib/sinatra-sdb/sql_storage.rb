module SDB

  class SqlStorage
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
        u.domains.map {|x| x.name}
      end

      def DomainMetadata(args)
        u = findUserByAccessKey(args[:key])
        d = u.domains.find_by_name(args[:domainName])
        
        r = {"ItemCount" => d.items.size,
             "ItemNamesSizeBytes" => d.items.inject{|sum,item| sum + item.name.size},
             "AttributeNameCount" => 103,
             "AttributeNamesSizeBytes" => 104,
             "AttributeValueCount" => 105,
             "AttributeValuesSizeBytes" => 106,
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
        Attr.transaction do
          updateItemAttrs(d, args[:itemName], args[:attributes])
        end
      end

      def BatchPutAttributes(args)
        u = findUserByAccessKey(args[:key])
        d = u.domains.find_by_name(args[:domainName])
        Attr.transaction do
          args[:items_attrs].each do |item|
            itemName,attributes = item
            updateItemAttrs(d, itemName, attributes)
          end
        end
      end
      
      #TODO we need handle del item or attr name only
      def DeleteAttributes(args)#(key, domainName, itemName, attributes)
        u = findUserByAccessKey(args[:key])
        d = u.domains.find_by_name(args[:domainName])
        i = d.items.find_by_name(args[:itemName])
        Attr.transaction do
          args[:attributes].each do |a|
            v = i.attrs.find_by_name_and_content(a[:name],a[:value])
            raise ServiceError.new("AttributeDoesNotExist",a[:name]) unless v
            v.destroy
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

      def updateItemAttrs(domain, itemName, attributes)
        i = domain.items.find_by_name(itemName)
        i = Item.create(:name => itemName, :domain => domain) if i.blank?
        attributes.each do |a|
          if a[:replace]
            need_del_attrs = i.attrs.find_all_by_name(a[:name])
            Attr.delete(need_del_attrs.map{|x|x.id})
          end
          begin
            Attr.create(:name => a[:name], :content => a[:value], :item => i)
          rescue ActiveRecord::RecordNotUnique => e
            pp e
            #raise
          end
        end
      end
    
  end

end
