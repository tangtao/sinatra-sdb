module SDB

  class ParamCheck

      def CreateDomain(args)
        verifyDomainName(args[:domainName])
      end

      def DeleteDomain(args)
        CreateDomain(args)
      end

      def ListDomains(args)
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
      end

      def BatchPutAttributes(args)
        verifyDomainName(args[:domainName])
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
        raise Error::MissingParameter_AttrName.new if attrName.blank?
        raise Error::InvalidParameterValue_AttrName.new if attrName.size > 1024
      end
    
  end

end
