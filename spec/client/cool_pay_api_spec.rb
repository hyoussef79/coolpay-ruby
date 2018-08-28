require 'spec_helper'

describe Client::CoolPayApi do
  subject { Client::CoolPayApi.new(username, apikey) }
  let(:username) { 'my_username' }
  let(:apikey) { 'my_apikey' }
  let(:base_uri) { Client::CoolPayApi.base_uri }
  let(:bearer_token) { 'b9863d39-32fe-4ee2-a248-2f5d3baf2e64' }
  let(:content_type) { 'application/json' }
  let(:recipient_name) { 'Jake McFriend' }

  before(:each) do
    token_response = {
      'token': bearer_token
    }.to_json

    stub_request(:post, "#{base_uri}/login").with(
      body: "username=#{username}&apikey=#{apikey}",
      headers: Client::CoolPayApi::DEFAULT_HEADERS
    ).to_return(
      status: 200,
      body: token_response,
      headers: {
        'Content-Type': content_type
      }
    )

    expected_recipients_body = {
      "recipients": [
        {
          "id": "6e7b4cea-5957-11e6-8b77-86f30ca893d3",
          "name": recipient_name
        }
      ]
    }.to_json

    stub_request(:get, "#{base_uri}/recipients").with(
      headers: {
        "Authorization"=>"Bearer #{bearer_token}" }
    ).to_return(
      status: 200,
      body: expected_recipients_body,
      headers: {
        'Content-Type': content_type
      }
    )
  end

  describe '#initialize' do
    it 'should initiate an object with username and apikey' do
      expect(subject.instance_variable_get(:@username)).to be(username)
      expect(subject.instance_variable_get(:@apikey)).to be(apikey)
    end
  end

  describe '#login' do
    it 'should login using @username and @apikey and return a bearer token' do
      response = subject.login
      expect(response).to match(bearer_token)
    end
  end

  describe '#recipients' do
    it 'should return recipients list' do
      response = subject.recipients
      expect(response).to be_an_instance_of(Array)
      expect(response.first['name']).to eq(recipient_name)
    end
  end
end
