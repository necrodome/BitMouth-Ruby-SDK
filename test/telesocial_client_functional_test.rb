require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../lib/telesocial')

class TelesocialClientTest < Test::Unit::TestCase

  def setup
    @client = Telesocial::Client.new("f180804f-5eda-4e6b-8f4e-ecea52362396")
  end

  def test_check_existing_network_id
    resp =  @client.get_registration_status("eric")
    assert 200 == resp.status
    assert resp.registered?
  end

  def test_check_non_existing_network_id
    assert_raise(Telesocial::NotFound) { @client.get_registration_status("erica_and_some_other_chars")}
  end

  # This test needs to improved due to the fact that
  # registration requires phone call.
  # def test_succesful_registration
  #  resp = @client.register("xxx", 1234567)
  #  assert 201, resp.status
  # end

  def test_create_media
    resp = @client.create_media("eric")
    assert 201 == resp.status
    assert resp.uri?
  end

  def test_request_upload_grant
    resp = @client.request_upload_grant("123c5e5b40c54eb198d69d64e37ed182")
    assert 201 == resp.status
  end

end
