class User
  include Mongoid::Document
  include SDB::Helpers
  include SDB::ModCommon::User
  references_many :domains

  field :email
  field :hashed_password
  field :salt
  field :is_admin
  field :key
  field :secret
  
  before_create  :generate_secret_and_key
end
