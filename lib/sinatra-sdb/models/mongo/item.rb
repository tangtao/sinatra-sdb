class Item
  include Mongoid::Document
  include SDB::ModCommon::Item
  references_many :attrs, :dependent => :destroy
  referenced_in :domain
    
  field :name
  field :meta
end