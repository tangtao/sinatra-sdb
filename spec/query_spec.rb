require File.dirname(__FILE__) + '/spec_helper'

describe "Query Action" do
  
  before(:all) do
    dbclean()
  end
  
  describe "All" do
    
    it "Single query Success" do
      attr1 = Attr.make!
      item = attr1.item
      domain = item.domain
      user = domain.user
      sdb = getSdb(user)
      query_expression = "['#{attr1.name}'='#{attr1.content}']"
      link = sdb.query_link(domain.name, query_expression)

      get link
      #pp last_response.body

      last_response.should be_ok
      checkResponse(last_response.body, 'ItemName').should == [item.name]
    end


  end

end
