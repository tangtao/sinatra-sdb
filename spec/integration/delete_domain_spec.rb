require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "DeleteDomain Action" do
  
  before(:each) do
    dbclean()
    @user = User.make!
    @domain = Domain.make!(:user => @user)
    @item1  = Item.make!(:domain => @domain)
    @attr1 = Attr.make(:item => @item1)

    @sdb = getSdb(@user)
  end

  describe "All" do
    
    it "Simple Delete" do
      link = @sdb.delete_domain_link(@domain.name)
      get link
  
      last_response.should be_ok
      @user.domains.count.should == 0
      Item.count.should == 0
      Attr.count.should == 0
    end

    it "Delete twice with same domain name" do
      link = @sdb.delete_domain_link(@domain.name)
      get link
      get link
  
      last_response.should be_ok
      @user.domains.count.should == 0
      Item.count.should == 0
      Attr.count.should == 0
    end

  end

end
