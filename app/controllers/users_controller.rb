class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  before_action :logged_in_user, only: [ :index, :edit, :update, :destroy ]
  before_action :correct_user, only: [ :edit, :update ]
  before_action :admin_user, only: [ :destroy ]

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Updated profile succsessfully!"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    redirect_to root_path, alert: "User not found" unless @user
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = "Please login!"
    redirect_to login_session_path
  end

  def correct_user
    return if current_user?(@user)

    flash[:danger] = "You don't have permission to access this page."
    redirect_to root_url
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = "Only admin have permission to delete user."
    redirect_to root_url
  end
end
