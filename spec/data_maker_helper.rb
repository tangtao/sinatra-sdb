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

  end
end
