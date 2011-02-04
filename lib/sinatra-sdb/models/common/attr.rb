module SDB
  module ModCommon
    module Attr

      def self.included(base)
        base.extend(ClassMethods)
      end
    
      protected
      
      def md5
        unless self.content.blank?
            self.md5sum = Digest::MD5.hexdigest(self.content)
        end
      end
    
      module ClassMethods
        def one_by_name_and_content(item, name, content)
          find(:first, :conditions => { :item_id => item.id, :name => name, :content => content })
        end
      
        def all_by_name(item, name)
          find(:all, :conditions => { :item_id => item.id, :name => name })
        end
      
        def one_by_name(item, name)
          find(:first, :conditions => { :item_id => item.id, :name => name })
        end
      end

    end
  end
end
