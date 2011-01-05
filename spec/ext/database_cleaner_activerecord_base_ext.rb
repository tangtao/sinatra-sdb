#
# 
#
module DatabaseCleaner
  module ActiveRecord
    module Base
     	def self.included(c)
    		c.class_eval do
    			def load_config
    				load_config_x
    			end
    		end
    	end

      def load_config_x
        self.connection_hash = ::ActiveRecord::Base.connection.instance_variable_get(:@config)
        unless self.connection_hash
          connection_details = YAML::load(ERB.new(IO.read(ActiveRecord.config_file_location)).result)
        	self.connection_hash = connection_details[self.db.to_s]
        end
      end
    end
  end
end
