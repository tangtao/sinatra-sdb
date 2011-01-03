require File.dirname(__FILE__) + '/spec_helper'

describe "ParamCheck" do

  before(:each) do
    @pchecker = SDB::ParamCheck.new
  end

  describe "DomainName" do
    it "too short" do
      params = {:DomainName => 'zz'}
      expect{@pchecker.CreateDomain(params)}.to raise_error(SDB::Error::InvalidParameterValue_DomainName)
    end
    it "too long" do
      params = {:DomainName => 'z'*260}
      expect{@pchecker.CreateDomain(params)}.to raise_error(SDB::Error::InvalidParameterValue_DomainName)
    end
    it "invalid char" do
      params = {:DomainName => "azqw123*"}
      expect{@pchecker.CreateDomain(params)}.to raise_error(SDB::Error::InvalidParameterValue_DomainName)
    end
    it "no domainName" do
      params = {}
      expect{@pchecker.CreateDomain(params)}.to raise_error(SDB::Error::MissingParameter_DomainName)
    end
  end

end
