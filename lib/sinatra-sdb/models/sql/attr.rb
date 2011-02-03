class Attr < ActiveRecord::Base

  belongs_to :item
  
  before_save  :md5

  def self.one_by_name_and_content(item, name, content)
    Attr.find(:first, :conditions => { :item_id => item.id, :name => name, :content => content })
  end

  def self.all_by_name(item, name)
    Attr.find(:all, :conditions => { :item_id => item.id, :name => name })
  end

  def self.one_by_name(item, name)
    Attr.find(:first, :conditions => { :item_id => item.id, :name => name })
  end


  protected
  
  def md5
    unless self.content.blank?
        self.md5sum = Digest::MD5.hexdigest(self.content)
    end
  end

end
