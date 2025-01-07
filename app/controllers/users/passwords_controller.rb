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
end

