require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "ListDomains Storage" do
  
  before(:all) do
    dbclean()
    @store = SDB::Storage::Store.new(SDB::Storage::SQL.new)
    @user = User.make!
    @domains = (0..9).map{Domain.make!(:user => @user)}
  end
    
  it "List Simple" do
    args = {:key => @user.key}
    
    ds,next_token = @store.ListDomains(args)
    ds.count.should == @domains.count
  end

  it "List by MaxNumberOfDomains" do
    maxnum = 3
    args = {:key => @user.key, :maxNumberOfDomains => maxnum}
    
    ds,next_token = @store.ListDomains(args)
    ds.count.should == maxnum
    next_token.should == 3
  end

  it "List by MaxNumberOfDomains and NextToken" do
    maxnum = 3
    [7,8,9].each do |token|
      args = {:key => @user.key, :maxNumberOfDomains => maxnum, :nextToken => token}
      ds,next_token = @store.ListDomains(args)
      ds.count.should == @domains.count - token
      ds.should == @domains[token,maxnum].map{|d|d.name}
      next_token.should be_nil
    end
  end

end
