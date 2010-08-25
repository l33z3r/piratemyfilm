require 'test_helper'

class ProjectsMailerTest < ActionMailer::TestCase
  tests ProjectsMailer
  def test_deliver_friend_invite
    @expected.subject = 'ProjectsMailer#deliver_friend_invite'
    @expected.body    = read_fixture('deliver_friend_invite')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ProjectsMailer.create_deliver_friend_invite(@expected.date).encoded
  end

end
