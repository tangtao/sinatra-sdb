class Domain

  include Mongoid::Document
  references_many :items, :dependent => :destroy
  referenced_in :user
  
  field :name

  def self.by_name(user, name)
    Domain.find(:first, :conditions => { :user_id => user.id, :name => name })
  end

end
