class UsersController < ApplicationController
  User = Struct.new(:id, :country)
  
  def new
    @user = User.new
  end
end
