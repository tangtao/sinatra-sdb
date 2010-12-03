require 'md5'
class Attr < ActiveRecord::Base

  belongs_to :item
  
  before_save  :md5

  protected
  
  def md5
    unless self.content.blank?
        self.md5sum = MD5.hexdigest(self.content)
    end
  end
  

end
