class Attr

  include Mongoid::Document
  include SDB::ModCommon::Attr
  referenced_in :item

  field :name
  field :content
  field :md5sum
  
  before_save  :md5

end
