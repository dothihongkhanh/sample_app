class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :destroy, :following, :followers ]
  before_action :logged_in_user, only: [ :index, :edit, :update, :destroy, :following, :followers ]
  before_action :correct_user, only: [ :edit, :update ]
  before_action :admin_user, only: [ :destroy ]

  def index
    @users = User.activated.paginate(page: params[:page])
  end

  def show
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
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

  def following
    @title = "Following"
    @users = @user.following.paginate(page: params[:page])
    render :show_follow
  end

  def followers
    @title = "Followers"
    @users = @user.followers.paginate(page: params[:page])
    render :show_follow
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    redirect_to root_path, alert: "User not found" unless @user
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def correct_user
    unless current_user?(@user)
      flash[:danger] = "You don't have permission to access this page."
      redirect_to root_url
    end
  end

  def admin_user
    unless current_user.admin?
      flash[:danger] = "Only admin have permission to delete user."
      redirect_to root_url
    end
  end
end
