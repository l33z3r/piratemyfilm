require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  tests Notifications
  def test_green_light
    @expected.subject = 'Notifications#green_light'
    @expected.body    = read_fixture('green_light')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_green_light(@expected.date).encoded
  end

  def test_my_green_light
    @expected.subject = 'Notifications#my_green_light'
    @expected.body    = read_fixture('my_green_light')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_my_green_light(@expected.date).encoded
  end

  def test_project_listed
    @expected.subject = 'Notifications#project_listed'
    @expected.body    = read_fixture('project_listed')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_project_listed(@expected.date).encoded
  end

  def test_my_project_fully_funded
    @expected.subject = 'Notifications#my_project_fully_funded'
    @expected.body    = read_fixture('my_project_fully_funded')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_my_project_fully_funded(@expected.date).encoded
  end

  def test_project_fully_funded
    @expected.subject = 'Notifications#project_fully_funded'
    @expected.body    = read_fixture('project_fully_funded')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_project_fully_funded(@expected.date).encoded
  end

  def test_project_90_percent_funded
    @expected.subject = 'Notifications#project_90_percent_funded'
    @expected.body    = read_fixture('project_90_percent_funded')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_project_90_percent_funded(@expected.date).encoded
  end

  def test_my_project_90_percent_funded
    @expected.subject = 'Notifications#my_project_90_percent_funded'
    @expected.body    = read_fixture('my_project_90_percent_funded')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_my_project_90_percent_funded(@expected.date).encoded
  end

  def test_my_pmf_rating_changed
    @expected.subject = 'Notifications#my_pmf_rating_changed'
    @expected.body    = read_fixture('my_pmf_rating_changed')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_my_pmf_rating_changed(@expected.date).encoded
  end

  def test_pmf_rating_changed
    @expected.subject = 'Notifications#pmf_rating_changed'
    @expected.body    = read_fixture('pmf_rating_changed')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_pmf_rating_changed(@expected.date).encoded
  end

end
