require File.dirname(__FILE__) + '/spec_helper'

describe "ParamCheck" do

  before(:each) do
    @pchecker = SDB::ParamCheck.new
  end

  describe "CreateDomain" do
    it "too short" do
      params = {:domainName => 'zz'}
      expect{@pchecker.CreateDomain(params)}.to raise_error(SDB::Error::InvalidParameterValue_DomainName)
    end
    it "too long" do
      params = {:domainName => 'z'*260}
      expect{@pchecker.CreateDomain(params)}.to raise_error(SDB::Error::InvalidParameterValue_DomainName)
    end
    it "invalid char" do
      params = {:domainName => "azqw123*"}
      expect{@pchecker.CreateDomain(params)}.to raise_error(SDB::Error::InvalidParameterValue_DomainName)
    end
    it "no domainName" do
      params = {}
      expect{@pchecker.CreateDomain(params)}.to raise_error(SDB::Error::MissingParameter_DomainName)
    end
  end

  describe "BatchPutAttributes" do
    it "DuplicateItemName" do
      params = {:domainName => 'zzz',
                :items_attrs => [["iname1",[{:name=>'attr1',:value=>'v1'}]],
                                 ["iname1",[{:name=>'attr2',:value=>'v2'}]],]
    }
      expect{@pchecker.BatchPutAttributes(params)}.to raise_error(SDB::Error::DuplicateItemName)
    end
  end

  describe "PutAttributes" do
    it "invalid item name" do
      params = {:domainName => 'zzz',
                :itemName => 'x'*1025,
                :attributes => [{:name => "iname1",:value => Set.new(['v1','v2'])},
                                {:name => "iname2",:value => Set.new(['v3','v4'])}]
    }
      expect{@pchecker.PutAttributes(params)}.to raise_error(SDB::Error::InvalidParameterValue_ItemName)
    end

    it "invalid attr name" do
      params = {:domainName => 'zzz',
                :itemName => 'x',
                :attributes => [{:name => "i"*1025,:value => Set.new(['v1','v2'])},
                                {:name => "iname2",:value => Set.new(['v3','v4'])}]
    }
      expect{@pchecker.PutAttributes(params)}.to raise_error(SDB::Error::InvalidParameterValue_AttrName)
    end

    it "invalid attr value" do
      params = {:domainName => 'zzz',
                :itemName => 'x',
                :attributes => [{:name => "iname1",:value => Set.new(['v'*1025,'v2'])},
                                {:name => "iname2",:value => Set.new(['v3','v4'])}]
    }
      expect{@pchecker.PutAttributes(params)}.to raise_error(SDB::Error::InvalidParameterValue_AttrValue)
    end

  end

  describe "ListDomains" do
    it "simple list" do
      params = {}
      @pchecker.ListDomains(params)
    end

    it "invalid MaxNumberOfDomains" do
      params = {:maxNumberOfDomains => 101}
      expect{@pchecker.ListDomains(params)}.to raise_error(SDB::Error::InvalidParameterValue_MaxNumberOfDomains)
    end

  end


end
