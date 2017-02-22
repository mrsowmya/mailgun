require "client.rb"
require "test/unit"

class TestClient < Test::Unit::TestCase

  def test_intialize
    client = Client.new({ email: 'manageremployeeapp@gmail.com', subject: 'Hello', text: 'Testing' })

    assert_equal(['manageremployeeapp@gmail.com'], client.email)
    assert_equal('Hello', client.subject)
    assert_equal('Testing', client.text)
    assert_equal(false, client.test_mode)
  end

  def test_send_email
    #this is the authorized email 'manageremployeeapp@gmail.com'
    client = Client.new({ email: 'manageremployeeapp@gmail.com', subject: 'Hello', text: 'Testing', test_mode: true })

    response = client.send_email
    assert_equal(200, response.code)
  end

  def test_send_email_if_email_is_blank
    client = Client.new({ subject: 'Hello', text: 'Testing', test_mode: true })

    response = client.send_email
    assert_equal("Error: Email can not be blank", response)
  end

  def test_send_email_if_email_is_supressions
    client = Client.new({ email: 'test@gmail.com', subject: 'Hello', text: 'Testing', test_mode: true })

    response = client.send_email
    assert_equal("Error: This email address is included in do not contact list", response)
  end

  def test_exceptions
    #Here I am sending not registered email id
    #It raises bad request

    client = Client.new({ email: 'test123@gmail.com', subject: 'Hello', text: 'Testing' })

    response = client.send_email
    assert_equal("400 Bad Request", response.message)
  end
end
