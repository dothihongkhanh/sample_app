require "test_helper"

class FollowActionTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_5)
    @other = users(:user_6)
    log_in_as(@user)
  end

  test "user can follow another user" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  test "user can unfollow another user" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference "@user.following.count", -1 do
      delete relationship_path(relationship)
    end
  end
end
