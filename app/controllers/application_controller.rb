class ApplicationController < ActionController::Base
  helper_method :login_partial
      
  private
      
  def login_partial
    user_signed_in? ? 'shared/logged_in' : 'shared/logged_out'
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname])
  end
end
