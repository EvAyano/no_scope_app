# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  def create
    if params[:user][:email].blank?
      flash[:alert] = "メールアドレスを入力してください。"
      redirect_to new_user_password_path
    else
      super
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    
    if resource.errors.empty?
      sign_out(resource)
      redirect_to password_reset_success_path
    else
      respond_with resource
    end
  end

  def password_reset_success
  end
end
