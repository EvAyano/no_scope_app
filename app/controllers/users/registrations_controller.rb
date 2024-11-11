# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :register_nickname_params, only: [:create]
  before_action :update_nickname_params, only: [:update]

  def edit_email
    @user = current_user
    render 'devise/registrations/edit_email'
  end

  def update_email
    @user = current_user
  
    if @user.update(email_params)
      redirect_to email_update_success_path
    else
      # できなかったら編集ページに戻る
      render 'devise/registrations/edit_email'
    end
  end
  

  def email_update_success
  end
  

  def edit_password
    @user = current_user
    render 'devise/registrations/edit_password'
  end

  # パスワード変更
  def update_password
    @user = current_user

    if @user.update_with_password(password_params)
      bypass_sign_in(@user)
      redirect_to password_update_success_path, notice: 'パスワードが更新されました。'
    else
      render 'devise/registrations/edit_password'
    end
  end

  def edit_nickname
    @user = current_user
  end

  def update_nickname
    @user = current_user
    if @user.update(nickname_params)
      redirect_to my_page_path, notice: 'ニックネームが更新されました。'
    else
      render :edit_nickname
    end
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
  
  def email_params
    params.require(:user).permit(:email)
  end

  def nickname_params
    params.require(:user).permit(:nickname)
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def email_params
    params.require(:user).permit(:email)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
