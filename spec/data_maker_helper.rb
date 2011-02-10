module SDB
  class DataMaker
    
    attr_reader   :user, :domain
    
    def initialize()
      @user = User.make!
      @domain = Domain.make!(:user => @user)
    end
    
    def createItem_one
      i = Item.make!(:domain => @domain)
      aa = []
      aa << Attr.make!(:item => i, :name => 'same_attr_name_01', :content => 'same_content_01')
      aa << Attr.make!(:item => i)
      aa << Attr.make!(:item => i, :name => 'same_attr_name_02', :content => 'same_content_02')
      aa << Attr.make!(:item => i, :name => 'same_attr_name_02', :content => 'same_content_03')
      
      [i, aa]
    end
    
    def createQueryItems
      items = []
      attrs = []
      
      item1  = Item.make!(:domain => @domain)
      attrs1 = { :a1 => Attr.make!(:item => item1),
                 :aY => Attr.make!(:item => item1, :name => 'year', :content => '2009') }
      items << item1
      attrs << attrs1
  
      item2  = Item.make!(:domain => @domain)
      attrs2 = { :a1  => Attr.make!(:item => item2),
                 :a2  => Attr.make!(:item => item2),
                 :a3  => Attr.make!(:item => item2, :name => "at3"),
                 :a3x => Attr.make!(:item => item2, :name => "at3"),
                 :aY  => Attr.make!(:item => item2,:name => 'year', :content => '2010') }
      items << item2
      attrs << attrs2
  
      item3 = Item.make!(:domain => @domain)
      attrs3 = { :a1 => Attr.make!(:item => item3, :name => attrs2[:a1].name, :content => attrs2[:a1].content),
                 :a2 => Attr.make!(:item => item3),
                 :a3 => Attr.make!(:item => item3, :name => attrs2[:a3].name, :content => attrs2[:a3].content),
                 :aY => Attr.make!(:item => item3, :name => 'year', :content => '2011') }
      items << item3
      attrs << attrs3
      [items, attrs]
    end

  end
end
