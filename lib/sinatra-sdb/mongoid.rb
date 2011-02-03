require "machinist"
require "machinist/machinable"

begin
  require "mongoid"
rescue LoadError
  puts "Mongoid is not installed (gem install mongoid)"
  exit
end

module Machinist
  
  module Mongoid
    
    module Machinable
      extend ActiveSupport::Concern
      
      module ClassMethods
        include Machinist::Machinable
        def blueprint_class
          Machinist::Mongoid::Blueprint
        end
      end
    end
    
    class Blueprint < Machinist::Blueprint
      
      def make!(attributes = {})
        object = make(attributes)
        object.save!
        object.reload
      end
      
      def lathe_class #:nodoc:
        Machinist::Mongoid::Lathe
      end
      
      def outside_transaction
        yield
      end
      
      def box(object)
        object.id
      end

      # Unbox an object from the warehouse.
      def unbox(id)
        @klass.find(id)
      end
    end
    
    class Lathe < Machinist::Lathe
      def make_one_value(attribute, args) #:nodoc:
        if block_given?
          raise_argument_error(attribute) unless args.empty?
          yield
        else
          make_association(attribute, args)
        end
      end
      
      def make_association(attribute, args) #:nodoc:
        association = @klass.associations[attribute.to_s]
        if association
          association.klass.make(*args)
        else
          raise_argument_error(attribute)
        end
      end
      
      def assign_attribute(key, value)
        @assigned_attributes[key.to_sym] = value
        if @object.respond_to?("#{key}=")
          @object.send("#{key}=", value)
        else
          @object.process(key => value)
        end
      end
    end
  end
end

module Mongoid #:nodoc:
  module Document #:nodoc:
    include Machinist::Mongoid::Machinable
  end
end

