class User < ActiveRecord::Base
  include SDB::ModCommon::User
  include SDB::Helpers

  has_many :domains

  before_create  :generate_secret_and_key

end
