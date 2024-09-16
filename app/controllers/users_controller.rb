class UsersController < ApplicationController
  before_action :authenticate_user!
  
  def my_page
    @user = current_user
    @lists = @user.lists
  end
end
