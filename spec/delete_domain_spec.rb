require File.dirname(__FILE__) + '/spec_helper'

describe "DeleteDomain Action" do
  
  before(:all) do
    dbclean()
  end
  
  before(:each) do
    @attr1 = Attr.make!
    @item1 = @attr1.item
    @domain = @item1.domain
    @user = @domain.user
    @sdb = getSdb(@user)
  end

  describe "All" do
    
    it "Simple Delete" do
      link = @sdb.delete_domain_link(@domain.name)
      get link
  
      last_response.should be_ok
      @user.domains.count.should == 0
      Attr.count.should == 0
      Item.count.should == 0
    end

    it "Delete twice with same domain name" do
      link = @sdb.delete_domain_link(@domain.name)
      get link
      get link
  
      last_response.should be_ok
      @user.domains.count.should == 0
      Attr.count.should == 0
      Item.count.should == 0
    end

  end

end
