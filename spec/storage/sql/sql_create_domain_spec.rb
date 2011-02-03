require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Create Domains Storage" do
  
  before(:all) do
    dbclean()
    @store = getStore
    @user = User.make!
  end
    
  it "Create Simple" do
    args = {:key => @user.key, :domainName => 'domain01'}
    
    @store.CreateDomain(args)
    @user.domains.count.should == 1
  end

end
