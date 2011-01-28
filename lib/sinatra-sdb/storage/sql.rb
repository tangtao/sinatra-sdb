module SDB
  module Storage
    class SQL
        def initialize()
        end
  
        def find_secret(key)
          u = User.find_by_key(key)
          u.secret if u
        end

        def domains_count(key)
          u = User.find_by_key(key)
          u.domains.count
        end
  
        def create_domain(key,name)
          u = User.find_by_key(key)
          Domain.find_or_create_by_user_id_and_name(u.id, name)
        end
  
        def delete_domain(key,name)
          u = User.find_by_key(key)
          d = u.domains.find_by_name(name)
          d.destroy if d
        end

        def find_domain_by_name(key,name)
          u = User.find_by_key(key)
          u.domains.find_by_name(name)
        end
  
        def domain_name_list(key)
          u = User.find_by_key(key)
          u.domains.map{|x| x.name}
        end

        def get_item_attrs(key,domain_name,item_name,attr_names=nil)
          u = User.find_by_key(key)
          d = u.domains.find_by_name(domain_name)
          i = d.items.find_by_name(item_name)
          return [] if i.blank?
          i.attrs_with_names(attr_names)
        end

        def put_one_item_attrs(key,domain_name,item_name, attributes)
          u = User.find_by_key(key)
          d = u.domains.find_by_name(domain_name)
          item = d.items.find_by_name(item_name)
          item = Item.create(:name => item_name, :domain => d) if item.blank?
          attributes.each do |a|
            if a[:replace]
              need_del_attrs = item.attrs.find_all_by_name(a[:name])
              Attr.destroy(need_del_attrs.map{|x|x.id})
            end
            a[:value].each { |v| Attr.create(:name => a[:name], :content => v, :item => item) }
          end
        end

        def delete_one_item_attrs(key,domain_name,item_name, attributes)
          u = User.find_by_key(key)
          d = u.domains.find_by_name(domain_name)
          i = d.items.find_by_name(item_name)
          
          if attributes.blank?
            i.destroy
          else
            attributes.each do |a|
              if a[:value].present?
                a[:value].each do |x|
                  v = i.attrs.find_by_name_and_content(a[:name],x)
                  v.destroy if v.present?
                end
              else
                Attr.destroy(i.attrs.find_all_by_name(a[:name]).map{|z| z.id})
              end
            end
            i.destroy if i.attrs.count == 0
          end
          
        end

        def verify_expected_value(key,domain_name,item_name, expecteds)
          return true if expecteds.blank?
          u = User.find_by_key(key)
          d = u.domains.find_by_name(domain_name)
          item = d.items.find_by_name(item_name)
          expecteds.each do |e|
            attrs = item.attrs.find_all_by_name(e[:name])
            if e[:exists]
              return false if attrs.blank?
            else
              return false if attrs[0].content != e[:value]
            end
          end
          true
        end
  
        def DomainMetadata(args)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
          
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
  
        def Query(args)#(key, domainName, queryExpression)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
  
          items,count = @query_executor.do_query(args[:queryExpression], d)
          items.map{|i|i.name}
        end
  
        def QueryWithAttributes(args)#(key, domainName, queryExpression)
          u = findUserByAccessKey(args[:key])
          d = u.domains.find_by_name(args[:domainName])
          attr_names = args[:attributeNames]
  
          items,count = @query_executor.do_query(args[:queryExpression], d)
          result = []
          items.each do |item|
            result << [item.name, getAttributesByNames(item, attr_names)]
          end
          result
        end
  
        def Select(args)#(key, queryExpression)
          u = findUserByAccessKey(args[:key])
          pp u
          @select_executor.do_query(args[:selectExpression], u)
        end

        private
        def findUserByAccessKey(key)
          User.find_by_key(key)
        end
  
        def getAttributesByNames(item, attr_names)
          result = []
          item.attrs.each do |a|
            if attr_names.include?(a.name)
              result << {:name => a.name, :value => a.content}
            end
          end
          result
        end
      
    end

    class SelectSQL
      
        attr_writer :sort_name, :sort_order, :limit_number, :explicit_attr_names
      
        def initialize(key)
          @user = User.find_by_key(key)
          @domain = nil
        end
        
        def domain=(name)
          @domain = @user.domains.find_by_name(name)
        end
        
        def all_items
          @domain.items
        end
        
        def items_sort_by_attr_name(items)
          return items if @sort_name.blank?
          items.sort do |a, b|
            a1 = a.attrs.find_by_name(@sort_name)
            b1 = b.attrs.find_by_name(@sort_name)
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
          item.attrs.find_all_by_name(attr_name)
        end
      
    end

  end
end
