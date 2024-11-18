require 'json'

class App
  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    case req.path_info
    when '/'
      res['Content-Type'] = 'application/json'
      res.write({ message: "Ruby API" }.to_json)
      res.status = 200
    else
      res['Content-Type'] = 'application/json'
      res.write({ error: "Page Not Found" }.to_json)
      res.status = 404
    end

    res.finish
  end
end
