module SDB
  class XmlRender
          
      def CreateDomain(params)
        xml do |x|
          x.CreateDomainResponse do
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end

      def DeleteDomain(params)
        xml do |x|
          x.DeleteDomainResponse do
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end

      def ListDomains(domains)
        xml do |x|
          x.ListDomainsResponse do
            x.ListDomainsResult do
              domains.each do |domain|
                x.DomainName domain
              end
            end
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
          
      end

      def DomainMetadata(metas)
        xml do |x|
          x.DomainMetadataResponse do
            x.DomainMetadataResult do
              metas.each do |k,v|
                x.tag!(k){|y| y << "#{v}"}
              end
            end
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end

      def GetAttributes(attrs)
        xml do |x|
          x.GetAttributesResponse do
            x.GetAttributesResult do
              attrs.each do |v|
                x.Attribute do
                  x.Name v[:name]
                  x.Value v[:value]
                end
              end
            end
            
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end

      def PutAttributes(params)
        xml do |x|
          x.PutAttributesResponse do
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end

      def BatchPutAttributes(params)
        xml do |x|
          x.BatchPutAttributesResponse do
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end

      def DeleteAttributes(params)
        xml do |x|
          x.DeleteAttributesResponse do
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end
      
      def Select(params)
        xml do |x|
          x.SelectResponse do
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end

      def Query(items)
                         
        xml do |x|
          x.QueryResponse do
            x.QueryResult do
              items.each do |i|
                x.ItemName i
              end
            end
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end

      def QueryWithAttributes(items)
                         
        xml do |x|
          x.QueryWithAttributesResponse do
            x.QueryWithAttributesResult do
              items.each do |item|
                iname, attrs = item
                x.Item do
                  x.ItemName iname
                  attrs.each do |a|
                    x.Attribute do
                      x.Name a[:name]
                      x.Value a[:value]
                    end
                  end
                end
              end
            end
            x.ResponseMetadata do
              x.RequestId requestId
              x.BoxUsage boxUsage
            end
          end
        end
      end
      

      private
      
      def xml
        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
        yield xml
        #content_type 'text/xml'
        #body xml.target!
      end
      
      def requestId
        UUIDTools::UUID.random_create.to_s
      end
      
      def boxUsage
        '0.0000219907'
      end
    
  end
end
