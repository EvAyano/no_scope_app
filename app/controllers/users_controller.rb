class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  
  def my_page
    @user = current_user
  end
  

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname, :avatar])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
  end
end
