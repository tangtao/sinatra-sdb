module SDB
  module Helpers
    #from right_aws
    class AwsUtils
      @@digest1   = OpenSSL::Digest::Digest.new("sha1")
      @@digest256 = nil
      if OpenSSL::OPENSSL_VERSION_NUMBER > 0x00908000
        @@digest256 = OpenSSL::Digest::Digest.new("sha256") rescue nil # Some installation may not support sha256
      end
      
      def self.amz_escape(param)
        param.to_s.gsub(/([^a-zA-Z0-9._~-]+)/n) do
          '%' + $1.unpack('H2' * $1.size).join('%').upcase
        end
      end
  

      # Signature Version 2
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
  
    end
  end
end
