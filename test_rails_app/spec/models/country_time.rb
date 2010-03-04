require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CountryTime do
  describe "in any given world" do
    before do
    end
    
    it 'should find_X_by_Y' do
       CountryTime::Country.find_a2_by_name("United States").should == "US"
    end
  end
end