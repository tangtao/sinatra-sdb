class Item < ActiveRecord::Base
  include SDB::ModCommon::Item

  has_many   :attrs, :dependent => :destroy
  belongs_to :domain
end