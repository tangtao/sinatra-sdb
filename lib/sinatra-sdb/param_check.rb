module SDB

  class ParamCheck

      def CreateDomain(args)
        verifyDomainName(args[:domainName])
      end

      def DeleteDomain(args)
        CreateDomain(args)
      end

      def ListDomains(args)
        maxDomains = args[:maxNumberOfDomains]
        if maxDomains.present?
          if maxDomains < 1 or maxDomains > 100
            raise Error::InvalidParameterValue_MaxNumberOfDomains.new([maxDomains])
          end
        end
      end

      def DomainMetadata(args)
        CreateDomain(args)
      end

      def GetAttributes(args)
        verifyDomainName(args[:domainName])
        verifyItemName(args[:itemName])
      end

      def PutAttributes(args)
        verifyDomainName(args[:domainName])
        verifyItemName(args[:itemName])
        args[:attributes].each do |a|
          verifyAttrName(a[:name])
          a[:value].each do |v|
            verifyAttrValue(v)
          end
        end
      end

      def BatchPutAttributes(args)
        verifyDomainName(args[:domainName])
        items_attrs = args[:items_attrs]
        item_names = items_attrs.map{|item| item[0]}
        if item_names.count > item_names.uniq.count
          raise Error::DuplicateItemName.new("xxx")
        end
        raise Error::NumberSubmittedItemsExceeded if item_names.count > 25
        items_attrs.each do |item|
          verifyItemName(item[0])
          raise Error::NumberSubmittedAttributesExceeded.new(item[0]) if item[1].count > 256
          raise Error::MissingParameter_NoAttributesForItem.new(item[0]) if item[1].count > 256
          item[1].each do |att|
            verifyAttrName(att[:name])
            verifyAttrValue(att[:value])
          end
        end
      end
      
      def DeleteAttributes(args)
        PutAttributes(args)
      end

      def Query(args)
        verifyDomainName(args[:domainName])
      end

      def QueryWithAttributes(args)
        result = Query(args)
      end

      def Select(args)
      end
      
      private
      
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
        raise Error::InvalidParameterValue_EmptyAttrName.new if attrName.blank?
        raise Error::InvalidParameterValue_AttrName.new if attrName.size > 1024
      end

      def verifyAttrValue(attrValue)
        raise Error::InvalidParameterValue_AttrValue.new if attrValue.size > 1024
      end
    
  end

end
