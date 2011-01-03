module SDB

  class ParamCheck
      def initialize()
      end

      def CreateDomain(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:domainName] = params[:DomainName]
        verifyDomainName(result[:domainName])
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
        result[:domainName] = params[:DomainName]
        verifyDomainName(result[:domainName])
        result[:itemName] = params[:ItemName]
        verifyItemName(result[:itemName])
        result[:attributeNames] = readAttrNames2Array(params)
        result
      end

      def PutAttributes(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:domainName] = params[:DomainName]
        verifyDomainName(result[:domainName])
        result[:itemName] = params[:ItemName]
        verifyItemName(result[:itemName])
        result[:attributes] = readAttrs2Array(params)
        result
      end

      def BatchPutAttributes(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:domainName] = params[:DomainName]
        verifyDomainName(result[:domainName])
        result[:items_attrs] = readBatchAttrs2Array(params)
        result
      end
      
      def DeleteAttributes(params)
        PutAttributes(params)
      end

      def Query(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:domainName] = params[:DomainName]
        verifyDomainName(result[:domainName])
        result[:queryExpression] = params[:QueryExpression]
        result
      end

      def QueryWithAttributes(params)
        result = Query(params)
        result[:attributeNames] = readAttrNames2Array(params)
        result
      end

      def Select(params)
        result = {}
        result[:key] = params[:AWSAccessKeyId]
        result[:selectExpression] = params[:SelectExpression]
        result
      end
      
      private
      
      def readAttrs2Array(params)
        result = []
        x = 0
        while params["Attribute.#{x}.Name"]
          a = {:name => params["Attribute.#{x}.Name"], 
               :value => params["Attribute.#{x}.Value"]}
          a[:replace] = true if params["Attribute.#{x}.Replace"] == "true"
          result << a
          
          x += 1
        end
        result
      end

      def readBatchAttrs2Array(params)
        result = []
        y = 0
        while params["Item.#{y}.ItemName"]
          x = 0
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

      def readAttrNames2Array(params)
        result = []
        x = 1
        while params["AttributeName.#{x}"]
          result << params["AttributeName.#{x}"]
          x += 1
        end
        result
      end

      def verifyDomainName(domainName)
        raise Error::MissingParameter_DomainName.new if domainName.blank?
        if domainName =~ /[^\w\-\.]/ or domainName.size < 3 or domainName.size > 255
          raise Error::InvalidParameterValue_DomainName.new([domainName])
        end
      end
      
      def verifyItemName(itemName)
        raise Error::MissingParameter_ItemName.new if itemName.blank?
        raise Error::InvalidParameterValue_ItemName.new if itemName.size > 1024
      end

      def verifyAttrName(attrName)
        raise Error::MissingParameter_AttrName.new if attrName.blank?
        raise Error::InvalidParameterValue_AttrName.new if attrName.size > 1024
      end
    
  end

end
