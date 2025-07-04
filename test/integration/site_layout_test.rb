require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "layout links when not logged in" do
    get root_path
    assert_template "static_pages/home"

    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", signup_users_path, count: 1

    assert_select "a[href=?]", help_static_pages_path
    assert_select "a[href=?]", about_static_pages_path
    assert_select "a[href=?]", contact_static_pages_path
    assert_select "a[href=?]", users_path, count: 0
  end

  test "layout links when logged in" do
    log_in_as(@user)
    get root_path

    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_static_pages_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_session_path
    assert_select "a[href=?]", about_static_pages_path
    assert_select "a[href=?]", contact_static_pages_path
  end

  test "signup page" do
    get signup_users_path
    assert_select "title", full_title("Sign up")
  end
end
