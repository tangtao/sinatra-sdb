module SDB
  class Action
      
      def initialize(render, storage)
        @render = render
        @storage = storage
        @paramchecker = ParamCheck.new
      end
          
      def runAction(params)
        begin
          checkSignature(params)
          
          action = params[:Action]
          result = @paramchecker.send(action, params)
          result = @storage.send(action, result)
          @render.send(action, result)
        
        rescue ServiceError => e
          handleError(e)
        rescue RuntimeError => e
          pp e
        end
      end
    

    private
    
    def checkSignature(params)
      strOldSignature = params[:Signature]
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
      
      #pp service_hash
      strSignature = Helpers::AwsUtils.genrate_signature_v2(find_secret_by_access_key(params[:AWSAccessKeyId]),
                                                  service_hash,
                                                  "GET", "localhost", "/")
      #pp strOldSignature
      #pp strSignature
      
      if strOldSignature != strSignature
        raise ServiceError.new("AuthFailure")
      end
    end
    
    def find_secret_by_access_key(key)
      u = User.find_by_key(key)
      raise ServiceError.new("AuthMissingFailure") unless u
      u.secret
    end

    def filterAttrs(params)
      result = {}
      params.each do |k,v|
          result[k] = v if k =~ /\.\d+\./  #match like "xxxx.1.xxxx"
      end
      result
    end
    
    def handleError(error)
       [error.status, error.msg]
    end
    
    
  end
end
