class Attr < ActiveRecord::Base
  include SDB::ModCommon::Attr
  belongs_to :item
  before_save  :md5
end
