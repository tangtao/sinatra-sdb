module SDB

  class ParamCheck
      def initialize()
      end

      def CreateDomain(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:domainName] = getAndCheckDomainName(params[:DomainName])
        result
      end

      def DeleteDomain(params)
        CreateDomain(params)
      end

      def ListDomains(params)
        {:key => params[:AWSAccessKeyId]}
      end

      def DomainMetadata(params)
        CreateDomain(params)
      end

      def GetAttributes(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:domainName] = getAndCheckDomainName(params[:DomainName])
        result[:itemName] = getAndCheckItemName(params[:ItemName])
        result
      end

      def PutAttributes(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:domainName] = getAndCheckDomainName(params[:DomainName])
        result[:itemName] = getAndCheckItemName(params[:ItemName])
        result[:attributes] = readAttrs2Array(params)
        result
      end

      def BatchPutAttributes(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:domainName] = getAndCheckDomainName(params[:DomainName])
        result[:items_attrs] = readBatchAttrs2Array(params)
        result
      end
      
      def DeleteAttributes(params)
        PutAttributes(params)
      end

      def Query(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:domainName] = getAndCheckDomainName(params[:DomainName])
        result[:queryExpression] = params[:QueryExpression]
        result
      end

      def QueryWithAttributes(params)
        Query(params)
      end
      
      private
      
      def readAttrs2Array(params)
        result = []
        x = 0
        while params["Attribute.#{x}.Name"]
          a = {:name => params["Attribute.#{x}.Name"], 
               :value => params["Attribute.#{x}.Value"]}
          a[:replace] = true if params["Attribute.#{x}.Replace"] == "true"
          result.push(a)
          
          x+=1
        end
        result
      end

      def readBatchAttrs2Array(params)
        result = []
        x = y = 0
        while params["Item.#{y}.ItemName"]
          item_attrs = []
          while params["Item.#{y}.Attribute.#{x}.Name"]
            a = {:name => params["Item.#{y}.Attribute.#{x}.Name"],
                 :value => params["Item.#{y}.Attribute.#{x}.Value"]}
            a[:replace] = true if params["Item.#{y}.Attribute.#{x}.Replace"] == "true"
            item_attrs << a
            
            x += 1
          end
          result << [params["Item.#{y}.ItemName"], item_attrs]
          y += 1
        end
        result
      end
      
      def getAndCheckDomainName(domainName)
        raise ServiceError.new("AuthFailureXX") if domainName.blank?
        domainName
      end
      
      def getAndCheckItemName(itemName)
        raise ServiceError.new("AuthFailureXX") if itemName.blank?
        itemName
      end
    
  end

end