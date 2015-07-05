require 'test_helper'

class GameControllerTest < ActionController::TestCase
  test "#play should load the canvas" do
    get :play
    assert_response :success
    # assert presence of canvas, text input?
  end
end
