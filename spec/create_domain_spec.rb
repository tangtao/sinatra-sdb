require File.dirname(__FILE__) + '/spec_helper'

describe "CreateDomain Action" do
 
  
  before(:each) do
    @user = User.make!
    @sdb = getSdb(@user)
  end
  
  describe "All" do
    
    it "Create Success" do
      @user.domains.count.should == 0
  
      link = @sdb.create_domain_link('books')
      get link
  
      last_response.should be_ok
      @user.domains.count.should == 1
    end
    
    it "Create twice with same domain name" do
      @user.domains.count.should == 0
  
      link = @sdb.create_domain_link('books')
      get link
      last_response.should be_ok
      @user.domains.count.should == 1
      
      link2 = @sdb.create_domain_link('books')
      get link2
  
      last_response.should be_ok
      @user.domains.count.should == 1
    end
  
  end

end
