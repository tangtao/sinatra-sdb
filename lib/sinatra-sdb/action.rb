module SDB
  class Action
      
      def initialize(render, storage)
        @render = render
        @storage = storage
        @parambuilder = ParamBuilder.new
        @paramchecker = ParamCheck.new
        @versions = {"2007-11-07" => ["CreateDomain","DeleteDomain","ListDomains",
                                        "DomainMetadata", "GetAttributes","PutAttributes","BatchPutAttributes",
                                        "DeleteAttributes","Query", "QueryWithAttributes", "Select"],
                       
                     "2009-04-15" => ["CreateDomain","DeleteDomain","ListDomains",
                                        "DomainMetadata", "GetAttributes","PutAttributes","BatchPutAttributes",
                                        "DeleteAttributes","Select"]
                    }
                                        
      end
          
      def runAction(params,request)
        begin
          checkVersion(params)
          checkSignature(params,request)
          action = params[:Action]
          result = @parambuilder.send(action, params)
          @paramchecker.send(action, result)
          result = @storage.send(action, result)
          @render.send(action, result)
        
        rescue Error::ServiceError => e
          handleError(e)
        end
      end
    

    private
    
    def checkSignature(params,request)
      strClientSignature = params[:Signature]
      service_hash = createServiceHash(params)
      strSignature = Helpers::AwsUtils.genrate_signature_v2(find_secret_by_access_key(params[:AWSAccessKeyId]),
                                                  service_hash,
                                                  "GET", request.host, request.path_info)
      
      if strClientSignature != strSignature
        raise ServiceError.new("AuthFailure")
      end
    end
    
    def checkVersion(params)
      unless @versions[params[:Version]].include?(params[:Action])
        raise ServiceError.new("AuthFailure")
      end
    end

    def createServiceHash(params)
      service_hash = {"Action" => params[:Action],
                      "Version" => params[:Version],
                      "AWSAccessKeyId" => params[:AWSAccessKeyId],
                      "SignatureVersion" => params[:SignatureVersion],
                      "Timestamp" => params[:Timestamp]}
                      
      %w(DomainName ItemName AttributeName MaxNumberOfDomains MaxNumberOfItems 
         NextToken SelectExpression QueryExpression).each do |key|
        service_hash[key] = params[key] if params.has_key?(key)
      end
      
      service_hash.merge!(filterAttrs(params))
      service_hash
    end
    
    def find_secret_by_access_key(key)
      @storage.FindSecretByAccessKey(key)
    end

    def filterAttrs(params)
      result = {}
      params.each do |k,v|
          result[k] = v if k =~ /\.\d+/  #match like "xxxx.1"
      end
      result
    end
    
    def handleError(error)
       [error.status, error.message]
    end
    
    
  end
end
