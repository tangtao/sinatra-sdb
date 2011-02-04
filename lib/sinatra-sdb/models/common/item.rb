module SDB
  module ModCommon
    module Item

      def self.included(base)
        base.extend(ClassMethods)
      end
    
      def attrs_with_names(names = nil)
        result = []
        attrs.each do |a|
          next if names.present? and (not names.include?(a.name))
          result << {:name => a.name, :value => a.content}
        end
        result
      end
    
      module ClassMethods
        def by_name(domain, name)
          find(:first, :conditions => { :domain_id => domain.id, :name => name })
        end
      end

    end
  end
end