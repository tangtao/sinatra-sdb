module SDB
  module Helpers
    class AwsUtils #:nodoc:
      @@digest1   = OpenSSL::Digest::Digest.new("sha1")
      @@digest256 = nil
      if OpenSSL::OPENSSL_VERSION_NUMBER > 0x00908000
        @@digest256 = OpenSSL::Digest::Digest.new("sha256") rescue nil # Some installation may not support sha256
      end
      
      # Escape a string accordingly Amazon rulles
      # http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?REST_RESTAuth.html
      def self.amz_escape(param)
        param.to_s.gsub(/([^a-zA-Z0-9._~-]+)/n) do
          '%' + $1.unpack('H2' * $1.size).join('%').upcase
        end
      end
  
      def self.time_now(service_hash)
        # TODO: verify effects of this for when Expires service_has is present
        is_gmt = service_hash["TimeRepresentation"] == "gmt"
        is_utc = service_hash["TimeRepresentation"] == "utc"
        t = Time.now unless is_gmt || is_utc
        t = Time.now.gmt if is_gmt
        t = Time.now.utc if is_utc
        return t
      end
  
      # Signature Version 2
      # EC2, SQS and SDB requests must be signed by this guy.
      # See:  http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?REST_RESTAuth.html
      #       http://developer.amazonwebservices.com/connect/entry.jspa?externalID=1928
      def self.genrate_signature_v2(aws_secret_access_key, service_hash, http_verb, host, uri)
        #fix_service_params(service_hash, '2')
        # select a signing method (make an old openssl working with sha1)
        # make 'HmacSHA256' to be a default one
        service_hash['SignatureMethod'] = 'HmacSHA256' unless ['HmacSHA256', 'HmacSHA1'].include?(service_hash['SignatureMethod'])
        service_hash['SignatureMethod'] = 'HmacSHA1'   unless @@digest256
        # select a digest
        digest = (service_hash['SignatureMethod'] == 'HmacSHA256' ? @@digest256 : @@digest1)
        # form string to sign
        canonical_string = service_hash.keys.sort.map do |key|
          "#{amz_escape(key)}=#{amz_escape(service_hash[key])}"
        end.join('&')
        string_to_sign = "#{http_verb.to_s.upcase}\n#{host.downcase}\n#{uri}\n#{canonical_string}"
        # sign the string
        #signature = amz_escape(Base64.encode64(OpenSSL::HMAC.digest(digest, aws_secret_access_key, string_to_sign)).strip)
        signature = Base64.encode64(OpenSSL::HMAC.digest(digest, aws_secret_access_key, string_to_sign)).strip
        # "#{canonical_string}&Signature=#{signature}"
        signature
      end
  
      # From Amazon's SQS Dev Guide, a brief description of how to escape:
      # "URL encode the computed signature and other query parameters as specified in 
      # RFC1738, section 2.2. In addition, because the + character is interpreted as a blank space 
      # by Sun Java classes that perform URL decoding, make sure to encode the + character 
      # although it is not required by RFC1738."
      # Avoid using CGI::escape to escape URIs. 
      # CGI::escape will escape characters in the protocol, host, and port
      # sections of the URI.  Only target chars in the query
      # string should be escaped.
      def self.URLencode(raw)
        e = URI.escape(raw)
        e.gsub(/\+/, "%2b")
      end
  
    end
  end
end
