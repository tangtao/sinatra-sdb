class Item < ActiveRecord::Base
    has_many   :attrs, :dependent => :destroy
    belongs_to :domain
    
    def attrs_with_names(names = nil)
      result = []
      attrs.each do |a|
        next if names.present? and (not names.include?(a.name))
        result << {:name => a.name, :value => a.content}
      end
      result
    end

  def self.by_name(domain, name)
    Item.find(:first, :conditions => { :domain_id => domain.id, :name => name })
  end
    
end