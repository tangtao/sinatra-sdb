module SDB
  module Storage
    class Default
        def initialize()
        end
  
        def find_secret(key)
          u = findUserByAccessKey(key)
          u.secret if u
        end

        def domains_count(key)
          u = findUserByAccessKey(key)
          u.domains.count
        end
  
        def create_domain(key,name)
          u = findUserByAccessKey(key)
          d = find_domain_by_name(key,name)
          Domain.create(:user => u, :name => name) if d.blank?
        end
  
        def delete_domain(key,name)
          d = find_domain_by_name(key,name)
          d.destroy if d
        end

        def find_domain_by_name(key,name)
          u = findUserByAccessKey(key)
          d = Domain.by_name(u, name)
        end
  
        def domain_name_list(key)
          u = findUserByAccessKey(key)
          u.domains.map{|x| x.name}
        end

        def get_item_attrs(key,domain_name,item_name,attr_names=nil)
          d = find_domain_by_name(key,domain_name)
          i = Item.by_name(d,item_name)
          return [] if i.blank?
          i.attrs_with_names(attr_names)
        end

        def put_one_item_attrs(key,domain_name,item_name, attributes)
          d = find_domain_by_name(key,domain_name)
          i = Item.by_name(d,item_name)
          i = Item.create(:name => item_name, :domain => d) if i.blank?
          attributes.each do |a|
            if a[:replace]
              Attr.all_by_name(i, a[:name]).each {|x| x.destroy}
            end
            a[:value].each { |v| Attr.create(:name => a[:name], :content => v, :item => i) }
          end
        end

        def delete_one_item_attrs(key,domain_name,item_name, attributes)
          d = find_domain_by_name(key,domain_name)
          i = Item.by_name(d,item_name)
          
          if attributes.blank?
            i.destroy
          else
            attributes.each do |a|
              if a[:value].present?
                a[:value].each do |x|
                  v = Attr.one_by_name_and_content(i, a[:name], x)
                  v.destroy if v.present?
                end
              else
                Attr.all_by_name(i, a[:name]).each{|z| z.destroy}
              end
            end
            i.destroy if i.attrs.count == 0
          end
          
        end

        def verify_expected_value(key,domain_name,item_name, expecteds)
          return true if expecteds.blank?
          d = find_domain_by_name(key,domain_name)
          item = Item.by_name(d, item_name)
          expecteds.each do |e|
            attrs = Attr.all_by_name(item, e[:name])
            if e[:exists]
              return false if attrs.blank?
            else
              return false if attrs[0].content != e[:value]
            end
          end
          true
        end
  
        def domain_metadata(key, domain_name)
          d = find_domain_by_name(key,domain_name)
          
          itemCount = d.items.size
          itemNamesSizeBytes = d.items.inject(0){|sum,item| sum + item.name.size}
          
          attributeNameCount = 0
          attributeNamesSizeBytes = 0
          d.items.each do |item|
            attr_set = Set.new(item.attrs.map{|a| a.name})
            attributeNameCount += attr_set.count
            attributeNamesSizeBytes += attr_set.inject(0){|sum,a| sum + a.size}
          end
          
          attributeValueCount = d.items.inject(0){|sum, item| sum + item.attrs.count}
          attributeValuesSizeBytes = d.items.inject(0) do |sum, item|
              sum + item.attrs.inject(0){|a_sum,a| a_sum + a.content.size}
          end
          
          r = {"ItemCount" => itemCount,
               "ItemNamesSizeBytes" => itemNamesSizeBytes,
               "AttributeNameCount" => attributeNameCount,
               "AttributeNamesSizeBytes" => attributeNamesSizeBytes,
               "AttributeValueCount" => attributeValueCount,
               "AttributeValuesSizeBytes" => attributeValuesSizeBytes,
               "Timestamp" => 1225486466
              }
        end
  
        private
        def findUserByAccessKey(key)
          User.by_key(key)
        end
      
    end

    class SelectDefault
      
        attr_writer :sort_name, :sort_order, :limit_number, :explicit_attr_names
      
        def initialize(key)
          @user = User.by_key(key)
          @domain = nil
        end
        
        def domain=(name)
          @domain = Domain.by_name(@user, name)
        end
        
        def all_items
          @domain.items
        end
        
        def items_sort_by_attr_name(items)
          return items if @sort_name.blank?
          items.sort do |a, b|
            a1 = Attr.one_by_name(a,@sort_name)
            b1 = Attr.one_by_name(b,@sort_name)
            if @sort_order == :asc
              a1.content <=> b1.content
            else
              b1.content <=> a1.content
            end
          end
        end

        def items_slice(items)
          return items if @limit_number.blank?
          items = items.to_a
          items[0, @limit_number]
        end

        def get_item_attrs(item)
          item.attrs_with_names(@explicit_attr_names)
        end
  
        def find_all_attr_by_name(item, attr_name)
          Attr.all_by_name(item, attr_name)
        end
      
    end

  end
end
