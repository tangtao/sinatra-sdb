class Domain < ActiveRecord::Base
  include SDB::ModCommon::Domain
  has_many :items, :dependent => :destroy
  belongs_to :user
end
