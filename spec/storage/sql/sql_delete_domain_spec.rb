require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Delete Domain Storage" do
  
  before(:all) do
    dbclean()
    @store = getStore
    @user = User.make!
    @domains = (0..3).map{Domain.make!(:user => @user)}
  end
    
  it "Delete Simple" do
    args = {:key => @user.key, :domainName => @domains[0].name}
    
    @store.DeleteDomain(args)
    @user.domains.count.should == @domains.count - 1
  end

end
