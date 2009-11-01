require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  integrate_views
  
  describe '#new' do
    before :each do
      get :new
    end
    
    it 'should show a country select with a3 codes' do
      response.should have_tag('select') do
        with_tag 'option[value=?]', 'AFG', :text => 'Afghanistan'
      end
    end
    
    it 'should show USA at the top of the select' do
      response.should have_tag('select') do
        with_tag 'option[value=?]:first-child', 'USA'
      end
    end
    
    it 'should allow name customization of countries' do
      response.should have_tag('select') do
        with_tag 'option[value=?]', 'TWN', :text => 'Taiwan'
      end
    end
  end
end
