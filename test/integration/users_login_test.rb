require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "login with invalid information" do
    get login_session_path
    assert_template "sessions/new"
    post login_session_path, params: { session: { email: "", password: "" } }
    assert_template "sessions/new"
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information" do
    get login_session_path
    assert_template "sessions/new"
    post login_session_path, params: { session: { email: @user.email, password: "password" } }

    assert_redirected_to @user
    follow_redirect!

    assert_template "users/show"
    assert_select "a[href=?]", login_session_path, count: 0
    assert_select "a[href=?]", logout_session_path
    assert_select "a[href=?]", user_path(@user)
  end

  test "login with valid email/invalid password" do
    get login_session_path
    assert_template "sessions/new"
    post login_session_path, params: { session: { email: @user.email, password: "invalid" } }
    assert_not is_logged_in?
    assert_template "sessions/new"
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_session_path
    assert_template "sessions/new"
    post login_session_path, params: { session: { email: @user.email, password: "password" } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    assert_select "a[href=?]", login_session_path, count: 0
    assert_select "a[href=?]", logout_session_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_session_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    delete logout_session_path
    follow_redirect!
    assert_select "a[href=?]", login_session_path
    assert_select "a[href=?]", logout_session_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: "1")
    assert_not_empty cookies[:remember_token]
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: 1)
    log_in_as(@user, remember_me: 0)
    assert_empty cookies[:remember_token]
  end
end
