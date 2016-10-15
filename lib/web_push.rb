require 'base64'
require 'net/https'
require 'openssl'
require 'securerandom'
require 'uri'
require 'ece'
require 'jwt'
require 'web_push/version'

class WebPush
  GROUP_NAME = 'prime256v1'
  DEFAULT_TTL = 60 * 60 * 24 * 7 * 4 # 4 weeks
  DEFAULT_EXP = 60 * 60 * 24 # 1 day

  module Utils
    # Save:
    #  pkey = generate_vapid_pkey
    #  File.write 'server.pem', pkey.to_pem
    # Load:
    #  OpenSSL::PKey.read File.read('server.pem')
    def self.generate_vapid_pkey
      OpenSSL::PKey::EC.new(GROUP_NAME).tap(&:generate_key)
    end
  end

  def initialize(subscription, ttl: DEFAULT_TTL, exp: DEFAULT_EXP)
    @subscription = subscription
    @endpoint = @subscription[:endpoint]
    @p256dh   = @subscription[:keys][:p256dh]
    @auth     = @subscription[:keys][:auth]
    @ttl = ttl
    @exp = exp
  end

  def send_notification(payload)
    params = generate_http_request(payload)

    uri = params[:uri]
    https = Net::HTTP.new uri.host, uri.port
    https.use_ssl = true

    request = Net::HTTP::Post.new uri.request_uri, params[:headers]
    request.body = params[:body]

    https.request request
  end

  def generate_http_request(payload)
    {
      method: 'POST',
      headers: {
        'TTL' => @ttl.to_s,
        'Content-Type' => 'application/octet-stream',
        'Content-Encoding' => 'aesgcm',
      },
      body: nil,
      uri: URI(@endpoint),
    }.tap do |request|
      encrypted = encrypt(@p256dh, @auth, payload)
      request[:headers]['Content-Length'] = encrypted[:cipher].bytesize.to_s
      request[:headers]['Encryption'] = 'salt=' + urlsafe_encode64(encrypted[:salt])
      request[:headers]['Crypto-Key'] = 'dh=' + urlsafe_encode64(encrypted[:server_public_key])
      request[:body] = encrypted[:cipher]

      audience = request[:uri].scheme + "://" + request[:uri].host
      vapid_headers = generate_vapid_headers audience
      request[:headers]['Authorization'] = vapid_headers['Authorization']
      request[:headers]['Crypto-Key'] += ';' + vapid_headers['Crypto-Key']
    end
  end

  def encrypt(p256dh, auth, payload)
    user_public_key = urlsafe_decode64 p256dh
    user_auth = urlsafe_decode64 auth

    local_curve = Utils.generate_vapid_pkey
    user_public_key_point = OpenSSL::PKey::EC::Point.new(local_curve.group, OpenSSL::BN.new(user_public_key, 2))

    key = local_curve.dh_compute_key(user_public_key_point)
    server_public_key = local_curve.public_key.to_bn.to_s(2)

    params = {
      key: key,
      salt: SecureRandom.random_bytes(16),
      server_public_key: server_public_key,
      user_public_key: user_public_key,
      auth: user_auth
    }
    params[:cipher] = ECE.encrypt(payload, params)

    params
  end

  def generate_vapid_headers(audience, sub: @vapid_subject, exp: @exp)
    jwt = JWT.encode({
                       aud: audience,
                       exp: Time.now.to_i + exp,
                       sub: sub,
                     }, @vapid_pkey, 'ES256')
    {
      'Authorization' => 'WebPush ' + jwt,
      'Crypto-Key' => 'p256ecdsa=' + urlsafe_encode64(@vapid_public_key_bn),
    }
  end

  def set_vapid_details(subject, public_key, private_key)
    @vapid_subject = subject
    @vapid_public_key = public_key
    @vapid_private_key = private_key
    @vapid_pkey = generate_vapid_pkey(@vapid_public_key, @vapid_private_key)
    @vapid_public_key_bn = @vapid_pkey.public_key.to_bn.to_s(2)
  end

  def generate_vapid_pkey(public_key, private_key)
    pvtbn = OpenSSL::BN.new(urlsafe_decode64(private_key), 2)
    pubbn = OpenSSL::BN.new(urlsafe_decode64(public_key), 2)

    pkey = Utils.generate_vapid_pkey
    pkey.private_key = pvtbn
    pkey.public_key = OpenSSL::PKey::EC::Point.new(pkey.group, pubbn)

    pkey
  end

  def urlsafe_encode64(bin)
    Base64.urlsafe_encode64(bin).delete('=')
  end

  def urlsafe_decode64(bin)
    Base64.urlsafe_decode64(bin)
  end
end
