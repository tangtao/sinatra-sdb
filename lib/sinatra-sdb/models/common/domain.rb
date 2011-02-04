module SDB
  module ModCommon
    module Domain

      def self.included(base)
        base.extend(ClassMethods)
      end
    
      module ClassMethods
        def by_name(user, name)
          find(:first, :conditions => { :user_id => user.id, :name => name })
        end
      end

    end
  end
end
