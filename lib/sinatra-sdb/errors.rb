module SDB
  module Error
    class ServiceError < Exception;end
    
    YAML::load(<<-END).
      AccessFailure: [ 403 , 'Access to the resource "%s" is denied.' ]
      AttributeDoesNotExist: [ 404 , 'Attribute ("%s") does not exist.' ]
      AuthFailure: [ 403 , 'AWS was not able to validate the provided access credentials.' ]
      AuthMissingFailure: [ 403 , 'AWS was not able to authenticate the request: access credentials are missing.' ]
      ConditionalCheckFailed: [ 409 , 'Conditional check failed. Attribute ("%s") value exists.' ]
      ConditionalCheckFailed: [ 409 , 'Conditional check failed. Attribute ("%s") value is ("%s") but was expected ("%s")' ]
      DuplicateItemName: [400, 'item "%s" was specified more than once.']
      ExistsAndExpectedValue: [ 400 , 'Expected.Exists=false and Expected.Value cannot be specified together' ]
      FeatureDeprecated: [ 400 , 'The replace flag must be specified per attribute, not per item.' ]
      IncompleteExpectedExpression: [ 400 , 'If Expected.Exists=true or unspecified, then Expected.Value has to be specified' ]
      InternalError: [ 500 , 'Request could not be executed due to an internal service error.' ]
      InvalidAction: [ 400 , 'The action "%s" is not valid for this web service.' ]
      InvalidHTTPAuthHeader: [ 400 , 'The HTTP authorization header is bad, use "%s".' ]
      InvalidHttpRequest: [ 400 , 'The HTTP request is invalid. Reason: "%s".' ]
      InvalidLiteral: [ 400 , 'Illegal literal in the filter expression.' ]
      InvalidNextToken: [ 400 , 'The specified next token is not valid.' ]
      InvalidNumberPredicates: [ 400 , 'Too many predicates in the query expression.' ]
      InvalidNumberValueTests: [ 400 , 'Too many value tests per predicate in the query expression.' ]
      InvalidParameterCombination: [ 400 , 'The parameter "%s" cannot be used with the parameter "%s".' ]
      InvalidParameterValue_MaxNumberOfDomains: [ 400 , 'Value ("%s") for parameter MaxNumberOfDomains is invalid. MaxNumberOfDomains must be between 1 and 100.' ]
      InvalidParameterValue: [ 400 , 'Value ("%s") for parameter MaxNumberOfItems is invalid. MaxNumberOfItems must be between 1 and 2500.' ]
      InvalidParameterValue: [ 400 , 'Value ("%s") for parameter "%s" is invalid. "%s".' ]
      InvalidParameterValue_ItemName: [ 400 , 'Value ("%s") for parameter Name is invalid. Value exceeds maximum length of 1024.' ]
      InvalidParameterValue_AttrName: [ 400 , 'Value ("%s") for parameter Name is invalid. Value exceeds maximum length of 1024.' ]
      InvalidParameterValue_AttrValue: [ 400 , 'Value ("%s") for parameter Value is invalid. Value exceeds maximum length of 1024.' ]
      InvalidParameterValue_DomainName: [400, 'Value ("%s") for parameter DomainName is invalid.']
      InvalidParameterValue: [ 400 , 'Value ("%s") for parameter Replace is invalid. The Replace flag should be either true or false.' ]
      InvalidParameterValue: [ 400 , 'Value ("%s") for parameter Expected.Exists is invalid. Expected.Exists should be either true or false.' ]
      InvalidParameterValue_EmptyAttrName: [ 400 , 'Value ("%s") for parameter Name is invalid.The empty string is an illegal attribute name' ]
      InvalidParameterValue: [ 400 , 'Value ("%s") for parameter ConsistentRead is invalid. The ConsistentRead flag should be either true or false.' ]
      InvalidQueryExpression: [ 400 , 'The specified query expression syntax is not valid.' ]
      InvalidResponseGroups: [ 400 , 'The following response groups are invalid: "%s".' ]
      InvalidService: [ 400 , 'The Web Service "%s" does not exist.' ]
      InvalidSOAPRequest: [ 400 , 'Invalid SOAP request. "%s".' ]
      InvalidSortExpression: [ 400 , 'The sort attribute must be present in at least one of the predicates, and the predicate cannot contain the is null operator.' ]
      InvalidURI: [ 400 , 'The URI "%s" is not valid.' ]
      InvalidWSAddressingProperty: [ 400 , 'WS-Addressing parameter "%s" has a wrong value: "%s".' ]
      InvalidWSDLVersion: [ 400 , 'Parameter ("%s") is only supported in WSDL version 2009-04-15 or beyond. Please upgrade to new version' ]
      MalformedSOAPSignature: [ 403 , 'Invalid SOAP Signature. "%s".' ]
      MissingAction: [ 400 , 'No action was supplied with this request.' ]
      MissingParameter: [ 400 , 'The request must contain the specified missing parameter.' ]
      MissingParameter: [ 400 , 'The request must contain the parameter "%s".' ]
      MissingParameter_ItemName: [400, 'The request must contain the parameter ItemName.']
      MissingParameter_DomainName: [400, 'The request must contain the parameter DomainName.']
      MissingParameter: [ 400 , 'Attribute.Value missing for Attribute.Name="%s".' ]
      MissingParameter: [ 400 , 'Attribute.Name missing for Attribute.Value="%s".' ]
      MissingParameter_NoAttributesForItem: [ 400 , 'No attributes for item ="%s".' ]
      MissingParameter: [ 400 , 'The request must contain the parameter Name' ]
      MissingWSAddressingProperty: [ 400 , 'WS-Addressing is missing a required parameter ("%s").' ]
      MultipleExistsConditions: [ 400 , 'Only one Exists condition can be specified' ]
      MultipleExpectedNames: [ 400 , 'Only one Expected.Name can be specified' ]
      MultipleExpectedValues: [ 400 , 'Only one Expected.Value can be specified' ]
      MultiValuedAttribute: [ 409 , 'Attribute ("%s") is multi-valued. Conditional check can only be performed on a single-valued attribute' ]
      NoSuchDomain: [400, 'The specified domain does not exist.']
      NoSuchVersion: [ 400 , 'The requested version ("%s") of service "%s" does not exist.' ]
      NotYetImplemented: [ 401 , 'Feature "%s" is not yet available.' ]
      NumberDomainsExceeded: [409, 'The domain limit was exceeded.']
      NumberDomainAttributesExceeded: [ 409 , 'Too many attributes in this domain.' ]
      NumberDomainBytesExceeded: [ 409 , 'Too many bytes in this domain.' ]
      NumberItemAttributesExceeded: [ 409 , 'Too many attributes in this item.' ]
      NumberSubmittedAttributesExceeded: [ 409 , 'Too many attributes in a single call.' ]
      NumberSubmittedAttributesExceeded: [ 409 , 'Too many attributes for item itemName in a single call. Up to 256 attributes per call allowed.' ]
      NumberSubmittedItemsExceeded: [ 409 , 'Too many items in a single call. Up to 25 items per call allowed.' ]
      RequestExpired: [ 400 , 'Request has expired. "%s" date is "%s".' ]
      RequestTimeout: [ 408 , 'A timeout occurred when attempting to query domain <%s> with query expression <%s>. BoxUsage <%s>".' ]
      ServiceUnavailable: [ 503 , 'Service Amazon SimpleDB is currently unavailable. Please try again later.' ]
      TooManyRequestedAttributes : [ 400 , 'Too many attributes requested.' ]
      UnsupportedHttpVerb: [ 400 , 'The requested HTTP verb is not supported: "%s".' ]
      UnsupportedNextToken: [ 400 , 'The specified next token is no longer supported. Please resubmit your query.' ]
      URITooLong: [ 400 , 'The URI exceeded the maximum limit of "%s".' ]
    END
    each do |code, (status, msg)|
      const_set(code, Class.new(ServiceError) do
        define_method(:initialize) do |*p|
          @params = p
        end
        {:code=>code, :status=>status}.each do |k,v|
          define_method(k) { v }
        end
        define_method(:message) do
          msg % @params
        end
      end)
    end
  
  end
end
