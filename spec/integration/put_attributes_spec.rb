require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "PutAttributes Action" do
  
  before(:each) do
    dbclean()

    @user = User.make!
    @domain = Domain.make!(:user => @user)
    @item  = Item.make!(:domain => @domain)
    @sdb = getSdb(@user)
  end
  
  describe "Base" do
    
    it "Simple Put" do
      attr1 = Attr.make(:item => @item)
      attrs = { attr1.name => attr1.content }
      link = @sdb.put_attributes_link(@domain.name, @item.name, attrs)

      get link
      #pp last_response.body

      last_response.should be_ok
      @item.attrs.count.should == 1
      @item.attrs[0].name.should == attr1.name
      @item.attrs[0].content.should == attr1.content
    end

    it "Put two Attrs with same name" do
      attr1 = Attr.make(:item => @item)
      attr2 = Attr.make(:item => @item, :name => attr1.name)
      attrs = { attr1.name => [attr1.content,attr2.content]}
      link = @sdb.put_attributes_link(@domain.name, @item.name, attrs)
      #pp link

      get link
      #pp last_response.body

      last_response.should be_ok
      @item.attrs.count.should == 2
      @item.attrs.map{|a|a.name}.should include(attr1.name)
      @item.attrs.map{|a|a.content}.should include(attr1.content,attr2.content)
    end


    it "Simple Put with replace" do
      
      attr1 = Attr.make!(:item => @item)
      attr1x = Attr.make(:item => @item, :name=>attr1.name)
      attrs = { attr1x.name => attr1x.content }
      link = @sdb.put_attributes_link(@domain.name, @item.name, attrs, true)

      get link
      #pp last_response.body

      last_response.should be_ok
      @item.attrs.count.should == 1
      @item.attrs.map{|a|a.name}.should include(attr1.name)
      @item.attrs.map{|a|a.content}.should include(attr1x.content)
    end

    it "Put two Attrs with same name and replace" do
      
      attr1 = Attr.make!(:item => @item)
      attr1x = Attr.make(:item => @item, :name=>attr1.name)
      attr1y = Attr.make(:item => @item, :name=>attr1.name)
      attrs = { attr1x.name => [attr1x.content, attr1y.content] }
      link = @sdb.put_attributes_link(@domain.name, @item.name, attrs, true)

      get link
      #pp last_response.body

      last_response.should be_ok
      @item.attrs.count.should == 2
      @item.attrs.map{|a|a.name}.should include(attr1.name)
      @item.attrs.map{|a|a.content}.should include(attr1x.content,attr1y.content)
    end

    it "Simple Put with replace and expecteds" do
      
      attr1 = Attr.make!(:item => @item)
      attr1x = Attr.make(:item => @item, :name=>attr1.name)
      attrs = { attr1x.name => attr1x.content }
      expecteds = {attr1.name => attr1.content}

      link = @sdb.put_attributes_link_new(@domain.name, @item.name, attrs, expecteds, true)

      get link
      #pp last_response.body

      last_response.should be_ok
      @item.reload
      @item.attrs.count.should == 1
      @item.attrs.map{|a|a.name}.should include(attr1.name)
      @item.attrs.map{|a|a.content}.should include(attr1x.content)
      @item.attrs.map{|a|a.content}.should_not include(attr1.content)
    end


  end

end
