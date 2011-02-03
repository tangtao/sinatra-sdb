require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "ListDomains Action" do
  
  before(:all) do
    dbclean()
    @user = User.make!
    @domains = (0..9).map{Domain.make!(:user => @user)}
    @sdb = getSdb(@user)

  end
  
  describe "Base" do
    it "List Simple" do
      link = @sdb.list_domains_link()
      get link
      last_response.should be_ok
      checkResponse(last_response.body, 'DomainName').count.should == @domains.count
    end
    it "List by MaxNumberOfDomains" do
      link = @sdb.list_domains_link(3)
      get link
      last_response.should be_ok
      checkResponse(last_response.body, 'DomainName').count.should == 3
    end
  end

end
