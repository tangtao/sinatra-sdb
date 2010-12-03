module SDB

  class SqlStorage
      def initialize()
        @query_executor = QueryExecutor.new
      end

      def findUserByAccessKey(key)
        User.find_by_key(key)
      end
    
      def CreateDomain(args)
        u = findUserByAccessKey(args[:key])
        d = Domain.find_or_create_by_user_id_and_name(u.id, args[:domainName])
      end

      def DeleteDomain(args)
        u = findUserByAccessKey(args[:key])
        d = u.domains.find_by_name(args[:domainName])
        d.destroy
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
        i = d.items.find_by_name(args[:itemName])
        i.attrs.map do |a|
          {:name => a.name, :value => a.content}
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

        items,count = @query_executor.do_query(args[:queryExpression], d)
        result = []
        items.each do |item|
          ats = []
          item.attrs.each do |a|
            ats << {:name => a.name, :value => a.content}
          end
          result << [item.name, ats]
        end
        result
      end
      
      private

      def updateItemAttrs(domain, itemName, attributes)
        i = domain.items.find_by_name(itemName)
        i = Item.create(:name => itemName, :domain => domain) unless i
        attributes.each do |a|
          if a[:replace]
            need_del_attrs = i.attrs.find_all_by_name(a[:name])
            Attr.delete(need_del_attrs.map{|x|x.id})
          end
          begin
            Attr.create(:name => a[:name], :content => a[:value], :item => i) unless a[:name] == 'id'
          rescue ActiveRecord::RecordNotUnique => e
            pp e
            #raise
          end
        end
      end
    
  end

end
