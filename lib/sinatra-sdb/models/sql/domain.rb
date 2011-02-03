class Domain < ActiveRecord::Base

  has_many :items, :dependent => :destroy
  belongs_to :user

  def self.by_name(user, name)
    Domain.find(:first, :conditions => { :user_id => user.id, :name => name })
  end

end
