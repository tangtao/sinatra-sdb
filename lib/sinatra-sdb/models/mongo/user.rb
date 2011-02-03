require 'digest/sha2'

class User
  include Mongoid::Document
  include SDB::Helpers
  references_many :domains

  field :email
  field :hashed_password
  field :salt
  field :is_admin
  field :key
  field :secret
 
  attr_accessor :password_confirmation
  attr_reader   :password

  before_create  :generate_secret_and_key
  
  def self.by_key(key)
    User.find(:first, :conditions => { :key => key })
  end

  def self.authenticate(email, password)
    user = User.find(:first, :conditions => { :email => email })
    if user.present?
      if user.hashed_password == encrypt_password(password, user.salt)
        user
      end
    end
  end

  def self.encrypt_password(password, salt)
    Digest::SHA2.hexdigest(password + "zzz" + salt)
  end
  
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
    
end
