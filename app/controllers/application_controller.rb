class ApplicationController < ActionController::Base
  helper_method :login_partial
      
  private
      
  def login_partial
    user_signed_in? ? 'shared/logged_in' : 'shared/logged_out'
  end
end
