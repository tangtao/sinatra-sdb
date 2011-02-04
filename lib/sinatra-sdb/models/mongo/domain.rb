class Domain

  include Mongoid::Document
  include SDB::ModCommon::Domain
  references_many :items, :dependent => :destroy
  referenced_in :user
  
  field :name

end
