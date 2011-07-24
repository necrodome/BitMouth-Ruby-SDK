require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../lib/bitmouth')

class BitMouthClientTest < Test::Unit::TestCase

  def test_check_existing_network_id
    resp =  @client.get_registration_status("eric")
    assert 200, resp.status
    assert resp.registered?
  end

  def test_check_non_existing_network_id
    assert_raise(BitMouth::NotFound) { @client.get_registration_status("erica")}
  end

  def test_succesful_registration
    resp = @client.register("xxx", 1234567)
    assert 201, resp.status
  end

  def setup
    @client = BitMouth::Client.new("key")

    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(
      :get, "https://api4.bitmouth.com/api/rest/registrant/eric?appkey=key&query=exists",
      :content_type => "application/json; charset=utf-8",
      :body => <<-JSON
        {"RegistrantResponse":{"message":"","status":200}}
      JSON
      )

    FakeWeb.register_uri(
      :get, "https://api4.bitmouth.com/api/rest/registrant/erica?appkey=key&query=exists",
      :content_type => "application/json; charset=utf-8",
      :body => <<-JSON
        {"RegistrantResponse":{"message":"","status":404}}
      JSON
      )

     FakeWeb.register_uri(
      :post, "https://api4.bitmouth.com/api/rest/registrant/",
      :data => {:name => "sdsd"},
      :content_type => "application/json; charset=utf-8",
      :body => <<-JSON
        {"RegistrationResponse":{"message":"","status":201,"uri":"\/api\/rest\/registrant\/1000022816599"}}
      JSON
      )
    end

end
