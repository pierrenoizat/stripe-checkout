#
# How to use : 
# bc_client = AutoRefreshToken.new
# bc_client.post('/api/v1/user/orders', params.to_json)
#

require 'oauth2'

class AutoRefreshToken

  # BC_APP_KEY      = 'ed43f6b5f2784d4b34270c58bab3e02cb1c32079f6058932390f8cba76ab272b' for boussac.75011+paymium@gmail.com
  # BC_APP_SECRET   = 'a08c1d123a657cff2c32abeb0d8ae37f7db80141452d8d1546b135c701e9e90d'
  
  BC_APP_KEY      = '11c80dd498527d27d3c3054dd47c908b2b180b2b471dfb5e146f958092f35ca6'  # bitspread
  BC_APP_SECRET   = '8fd5bc067df2b8046360d0832f59cd40acab3832f8f8007637018f7d9f3d22ea'

  EXPIRATION_TIME = 1200

  TOKEN_FILE = File.expand_path('~/.bot/token.json')

  def initialize
    self.token = get_initial_token
    persist!
  end

  def get(uri)
    token.get(uri)
  end

  def post(uri, data)
    token.post(uri, body: data, headers: { "Content-Type" => "application/json" })
  end

  def token
    @last_request ||= Time.now

    if (Time.now - @last_request) > EXPIRATION_TIME
      @last_request = Time.now
      refresh!
    end

    @token
  end

  def token=(t)
    @token = t
    persist!
  end

  def get_initial_token
    authorization_code = nil
    client = OAuth2::Client.new(BC_APP_KEY, BC_APP_SECRET, site: 'https://bitcoin-central.net', authorize_url: '/api/oauth/authorize', token_url: '/api/oauth/token')

    if File.exist?(TOKEN_FILE)
      @token = OAuth2::AccessToken.from_hash(client, read_from_file)
      refresh!
    else
      url = client.auth_code.authorize_url(redirect_uri: 'https://bitcoin-central.net/page/oauth/test', scope: 'basic activity trade withdraw')
      system("open \"#{url}\"")

      puts "Put the token in authorization_code and exit prompt"
      binding.pry

      @last_request = Time.now
      self.token = client.auth_code.get_token(authorization_code, redirect_uri: 'https://bitcoin-central.net/page/oauth/test')
    end

    @token
  end

  def read_from_file
    JSON.load(File.read(TOKEN_FILE))
  end

  def persist!
    File.open(TOKEN_FILE, 'wb') { |f| f.write(@token.to_json) }
  end

  def refresh!
    self.token = token.refresh!
  end

end

