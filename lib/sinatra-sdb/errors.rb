module SDB

  # All errors are derived from ServiceError.  It's never actually raised itself, though.
  class ServiceError < Exception
    
    attr_accessor :status, :msg
    
    # A factory for building exception classes.
    @@error_table = {}
    YAML::load(<<-END).
        AccessFailure: [403, Access to the resource resourceName is denied.]
        AttributeDoesNotExist: [404, Attribute '%s' does not exist.]
        AuthFailure: [403, AWS was not able to validate the provided access credentials.]
        AuthMissingFailure: [403, AWS was not able to authenticate the request access credentials are missing.]
        ConditionalCheckFailed: [409, Conditional check failed. Attribute value exists.]
    END
    each do |code, (status, msg)|
      @@error_table[code] = [status, msg]
    end

    def initialize(code, params=[])
      @status = @@error_table[code][0]
      @msg = @@error_table[code][1] % params
    end
  
  end

end
