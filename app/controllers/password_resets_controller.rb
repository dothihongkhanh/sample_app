class PasswordResetsController < ApplicationController
  before_action :get_user, only: [ :edit, :update ]
  before_action :valid_user, only: [ :edit, :update ]
  before_action :check_expiration, only: [ :edit, :update ]

  def new
  end

  def create
    @user = User.find_by(email: password_reset_params[:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if user_params[:password].blank?
      @user.errors.add(:password, "can't be empty")
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      log_in @user
      @user.update_columns(reset_digest: nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def password_reset_params
    params.require(:password_reset).permit(:email)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])

    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = "Password reset has expired."
    redirect_to new_password_reset_url
  end
end
