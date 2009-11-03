require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe UsersController do
  integrate_views
  
  describe '#new' do
    before :each do
      get :new
    end
    
    it 'should let you rename countries by passing a hash to .rename_countries' do
      response.should have_tag('select') do
        with_tag 'option[value=?]', 'IRN', :text => 'Iran'
        with_tag 'option[value=?]', 'PSE', :text => 'Palestine'
      end
    end
  end
end
