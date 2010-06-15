require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  load_all_fixtures
  
  context 'A User instance' do
    should_require_attributes :login, :password, :password_confirmation
    should_require_unique_attributes :login

    should_ensure_length_in_range :login, 3..40
    should_ensure_length_in_range :password, 4..40
    should_protect_attributes :is_admin, :can_send_messages

    should 'be able to change their password' do
      assert p = users(:user).crypted_password
      assert u2 = User.find(users(:user).id)
      assert u2.change_password('test', 'asdfg', 'asdfg')
      assert u2.valid?
      assert_not_equal(p, u2.crypted_password)
    end

    should 'require the correct current password in order to change password' do
      assert p = users(:user).crypted_password
      assert u2 = User.find(users(:user).id)
      assert !u2.change_password('tedst', 'asdfg', 'asdfg')
      assert u2.valid?
      assert_equal(p, u2.crypted_password)
    end

    should 'require a matching password confirmation to change password' do
      assert p = users(:user).crypted_password
      assert u2 = User.find(users(:user).id)
      assert !u2.change_password('test', 'asdfg', 'asdfgd')
      assert u2.valid?
      assert_equal(p, u2.crypted_password)
    end

    should 'reset password if forgotten' do
      p1 = users(:user).crypted_password
      assert users(:user).forgot_password
      assert_not_equal p1, users(:user).reload.crypted_password
    end
    
  end
end
