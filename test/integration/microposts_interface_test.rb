require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select "div.pagination"
    assert_select "input[type=file]"

    # invalid submission
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select "div#error_explanation"
    assert_select "a[href=?]", "/?page=2"

    # valid submission
    content = "This is content"
    image = fixture_file_upload("test/fixtures/kitten.jpg", "image/jpeg")
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: { micropost: { content: content, image: image } }
    end
    micropost = assigns(:micropost)
    assert micropost.image.attached?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    # delete post
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end

    # visit different user (no delete links)
    get user_path(users(:two))
    assert_select "a", text: "delete", count: 0
  end

  test "micropost sidebar count" do
    # user has many microposts
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body

    # user has no microposts yet
    other_user = users(:two)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body

    # user has exactly 1 micropost
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1 micropost", response.body
  end
end
