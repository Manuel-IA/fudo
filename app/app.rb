require 'json'
require 'jwt'
require_relative './controllers/product_controller'

class App
  SECRET_KEY = 'my$ecretK3y'

  def initialize
    @product_controller = ProductController.new
    @product_controller.process_queue
  end

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
    when '/products'
      user_data = authenticate_token(req, res)
      if user_data
        req.post? ? @product_controller.create(req, res, user_data) : @product_controller.index(req, res, user_data)
      else
        res['Content-Type'] = 'application/json'
        res.write({ error: "Unauthorized" }.to_json)
        res.status = 401
      end
    when %r{/products/\w+}
      user_data = authenticate_token(req, res)
      if user_data
        if req.get?
          @product_controller.show(req, res, user_data)
        elsif req.put?
          @product_controller.update(req, res, user_data)
        elsif req.delete?
          @product_controller.delete(req, res, user_data)
        else
          res['Content-Type'] = 'application/json'
          res.write({ error: "Method not allowed" }.to_json)
          res.status = 405
        end
      else
        res['Content-Type'] = 'application/json'
        res.write({ error: "Unauthorized" }.to_json)
        res.status = 401
      end
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

  def authenticate_token(req, res)
    auth_header = req.env['HTTP_AUTHORIZATION']
    if auth_header && auth_header.start_with?('Bearer ')
      token = auth_header.split(' ').last
      begin
        decoded = decode_jwt(token)
        decoded
      rescue JWT::DecodeError
        res['Content-Type'] = 'application/json'
        res.write({ error: "Invalid token" }.to_json)
        res.status = 401
        return nil
      end
    else
      res['Content-Type'] = 'application/json'
      res.write({ error: "Authorization header missing or invalid" }.to_json)
      res.status = 401
      return nil
    end
  end
end
