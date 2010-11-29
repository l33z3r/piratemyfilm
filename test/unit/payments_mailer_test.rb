require 'test_helper'

class PaymentsMailerTest < ActionMailer::TestCase
  tests PaymentsMailer
  def test_window_opened
    @expected.subject = 'PaymentsMailer#window_opened'
    @expected.body    = read_fixture('window_opened')
    @expected.date    = Time.now

    assert_equal @expected.encoded, PaymentsMailer.create_window_opened(@expected.date).encoded
  end

  def test_window_closed
    @expected.subject = 'PaymentsMailer#window_closed'
    @expected.body    = read_fixture('window_closed')
    @expected.date    = Time.now

    assert_equal @expected.encoded, PaymentsMailer.create_window_closed(@expected.date).encoded
  end

  def test_payment_succeeded
    @expected.subject = 'PaymentsMailer#payment_succeeded'
    @expected.body    = read_fixture('payment_succeeded')
    @expected.date    = Time.now

    assert_equal @expected.encoded, PaymentsMailer.create_payment_succeeded(@expected.date).encoded
  end

  def test_payment_defaulted
    @expected.subject = 'PaymentsMailer#payment_defaulted'
    @expected.body    = read_fixture('payment_defaulted')
    @expected.date    = Time.now

    assert_equal @expected.encoded, PaymentsMailer.create_payment_defaulted(@expected.date).encoded
  end

end
