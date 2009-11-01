require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe UsersController do
  integrate_views
  
  describe '#new' do
    before :each do
      get :new
    end
    
    it 'should show a country select with names as values' do
      response.should have_tag('select') do
        with_tag 'option[value=?]', 'Afghanistan', :text => 'Afghanistan'
      end
    end
    
    it 'should show an added country' do
      response.should have_tag('select') do
        with_tag 'option[value=?]', 'Scotland', :text => 'Scotland'
      end
    end
    
    it 'should let you rename countries by name' do
      response.should have_tag('select') do
        with_tag 'option[value=?]', 'Iran', :text => 'Iran'
      end
    end
    
    it 'should let you skip a country in the select call' do
      response.should_not have_tag('option[value=?]', 'Syrian Arab Republic')
    end
  end
end
