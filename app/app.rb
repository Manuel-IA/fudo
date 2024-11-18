require 'json'
require 'jwt'

class App
  SECRET_KEY = 'my$ecretK3y'

  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    case req.path_info
    when '/'
      res['Content-Type'] = 'application/json'
      res.write({ message: "Ruby API" }.to_json)
      res.status = 200
    when '/auth'
      authenticate(req, res)
    else
      res['Content-Type'] = 'application/json'
      res.write({ error: "Page Not Found" }.to_json)
      res.status = 404
    end

    res.finish
  end

  private

  def authenticate(req, res)
    if req.post?
      username = req.params['username']
      password = req.params['password']

      if username == 'admin' && password == 'password'
        token = generate_jwt(username)
        res['Content-Type'] = 'application/json'
        res.write({ message: "Authentication Successful", token: token }.to_json)
        res.status = 200
      else
        res['Content-Type'] = 'application/json'
        res.write({ error: "Unauthorized" }.to_json)
        res.status = 401
      end
    else
      res['Content-Type'] = 'application/json'
      res.write({ error: "Method Not Allowed" }.to_json)
      res.status = 405
    end
  end

  def generate_jwt(username)
    payload = {
      username: username,
      exp: Time.now.to_i + 3600
    }
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def decode_jwt(token)
    decoded_token = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    decoded_token.first
  end
end
