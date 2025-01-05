# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, only: [:create, :update]

  def edit_email
    @user = current_user
    render 'devise/registrations/edit_email'
  end

  def update_email
    @user = current_user

    if @user.update(email_params)
      render :email_update_success
    else
      flash[:alert] = @user.errors.full_messages
      redirect_to edit_user_email_path
    end
  end

  def email_update_success; end

  def edit_password
    @user = current_user
    render 'devise/registrations/edit_password'
  end

  def update_password
    @user = current_user

    if params[:user][:current_password].blank?
      @user.errors.add(:current_password, "を入力してください")
    end

    if params[:user][:password].blank?
      @user.errors.add(:password, "を入力してください")
    end

    if params[:user][:password_confirmation].blank?
      @user.errors.add(:password_confirmation, "を入力してください")
    end

    if @user.errors.any?
      flash[:alert] = @user.errors.full_messages
      redirect_to edit_custom_user_password_path and return
    end
    

    if @user.update_with_password(password_params)
      bypass_sign_in(@user)
      redirect_to password_update_success_path
    else
      flash[:alert] = @user.errors.full_messages.join(", ")
      redirect_to edit_custom_user_password_path and return
    end
  end

  def edit_nickname
    @user = current_user
  end

  def update_nickname
    @user = current_user

    if params[:user][:nickname].blank?
      @user.errors.add(:nickname, "を入力してください")
    elsif params[:user][:nickname].length > 10
      @user.errors.add(:nickname, "は10文字以内で入力してください")
    end

    if @user.errors.any?
      flash[:alert] = @user.errors.full_messages
      redirect_to edit_user_nickname_path and return
    end

    if @user.update(nickname_params)
      redirect_to edit_user_registration_path
    end
  end

  def edit_avatar
    @user = current_user
    render 'devise/registrations/edit_avatar'
  end

  def update_avatar
    @user = current_user

    if @user.update(user_avatar_params)
      redirect_to edit_user_registration_path
    else
      redirect_to edit_user_avatar_path and return
    end
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def nickname_params
    params.require(:user).permit(:nickname)
  end
  
  def user_avatar_params
    params.require(:user).permit(:avatar)
  end

  protected

  def email_params
    params.require(:user).permit(:email)
  end
end
