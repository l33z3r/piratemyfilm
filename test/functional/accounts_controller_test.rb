require File.dirname(__FILE__) + '/../test_helper'

class AccountsControllerTest < ActionController::TestCase

  VALID_USER = {
    :login => 'lquire',
    :email => 'lquire@example.com',
    :password => 'lquire', :password_confirmation => 'lquire',
    :terms_of_service=>'1'
  }
  
  def setup
    @controller = AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context 'A visitor' do
    should 'be able to signup' do
      assert_difference "User.count" do
        post :signup, {:user => VALID_USER}
        assert_response :redirect
        assert assigns['u']
        assert_redirected_to profile_path(assigns['u'].profile)
        assert_equal 'Thanks for signing up!', flash[:notice]
      end
    end
  end
  
end
