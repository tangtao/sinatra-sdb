module SDB
  class Store
    def initialize(storge)
      @storge = storge
      @query_executor = QueryExecutor.new
      @select_executor = SelectExecutor.new
    end

    def FindSecretByAccessKey(key)
      secret = @storge.find_secret(key)
      raise Error::AuthMissingFailure.new if secret.blank?
      secret
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
      raise Error::NoSuchDomain.new if @storge.find_domain_by_name(args[:key],args[:domainName]).blank?
      @storge.domain_metadata(args[:key],args[:domainName])
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
      items,count = @query_executor.do_query(args[:key],args[:domainName],args[:queryExpression])
      items.map{|i|i.name}
    end

    def QueryWithAttributes(args)#(key, domainName, queryExpression)
      attr_names = args[:attributeNames]
      items,count = @query_executor.do_query(args[:key],args[:domainName],args[:queryExpression])
      result = []
      items.each do |item|
        result << [item.name, getAttributesByNames(item, attr_names)]
      end
      result
    end

    def Select(args)#(key, queryExpression)
      @select_executor.do_query(args[:selectExpression], args[:key])
    end

    
    private

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
