require 'digest/sha2'

module SDB
  module ModCommon
    module User

      def self.included(base)
        base.extend(ClassMethods)
      end

      attr_accessor :password_confirmation
      attr_reader   :password
      
    
      # 'password' is a virtual attribute
      def password=(password)
        @password = password
    
        if password.present?
          generate_salt
          self.hashed_password = self.class.encrypt_password(password, salt)
        end
      end
  
      private
      def generate_salt
        self.salt = self.object_id.to_s + rand.to_s
      end
      def generate_secret_and_key
        if self.key.blank?
            self.key = generate_key
            self.secret = generate_secret
        end
      end
    
      module ClassMethods
        def by_key(key)
          find(:first, :conditions => { :key => key })
        end
      
        def authenticate(email, password)
          user = find(:first, :conditions => { :email => email })
          if user.present?
            if user.hashed_password == encrypt_password(password, user.salt)
              user
            end
          end
        end
      
        def encrypt_password(password, salt)
          Digest::SHA2.hexdigest(password + "zzz" + salt)
        end
      end

    end
  end
end
