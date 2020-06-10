require 'test_helper'

class VoterControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get voter_index_url
    assert_response :success
  end

end
