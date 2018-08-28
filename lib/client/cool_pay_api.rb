require 'HTTParty'

module Client
  class CoolPayApi
    include HTTParty
  
    VERSION = '1.0'.freeze
    DEFAULT_HEADERS = {
      'User-Agent': "Cool-Pay-Api-Client/#{VERSION}"
    }.freeze
    
    base_uri 'coolpay.herokuapp.com/api'
  
    def initialize(username, apikey)
      @username = username
      @apikey = apikey
      @debug = ENV.fetch('DEBUG', false)
    end

    def login
      handle_response do
        self.class.post('/login', request(body: credentials))
      end['token']
    end

    def recipients(query = {})
      handle_response do
        self.class.get('/recipients', authenticated_request(query: query))
      end['recipients']
    end

    def create_recipient(body = {})
      handle_response do
        self.class.post('/recipients', authenticated_request(body: body))
      end['recipient']
    end

    def payments
      handle_response do
        self.class.get('/payments', authenticated_request)
      end['payments']
    end

    def create_payment(body = {})
      handle_response do
        self.class.post('/payments', authenticated_request(body: body))
      end['payment']
    end

    private

    def handle_response
      begin
        response = yield
        return response.parsed_response if response.response.kind_of?(Net::HTTPSuccess)
        raise 'Oooops'
      end
    end

    def bearer_token
      @bearer_token ||= login
    end

    def credentials
      {
        username: @username,
        apikey: @apikey
      }
    end

    def default_headers(headers = {})
      headers.merge(DEFAULT_HEADERS)
    end

    def request(options = {})
      options[:headers] = default_headers(options.fetch(:headers, {}))
      options[:debug_output] = STDOUT if @debug
      options
    end

    def authenticated_request(options = {})
      options[:headers] = options.fetch(:headers, {}).merge({
        'Authorization': "Bearer #{bearer_token}"
      })
      request(options)
    end
  end
end
