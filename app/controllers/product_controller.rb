class ProductController
  @@products = []

  def create(req, res, _user_data)
    if req.post?
      name = req.params['name']
      id = req.params['id']

      if name.nil? || id.nil?
        res['Content-Type'] = 'application/json'
        res.write({ error: "Missing parameters: 'name' and 'id' are required" }.to_json)
        res.status = 400
        return
      end

      product = { id: id, name: name }
      @@products << product

      res['Content-Type'] = 'application/json'
      res.write({ message: "Product created successfully", product: product }.to_json)
      res.status = 201
    else
      res['Content-Type'] = 'application/json'
      res.write({ error: "Method Not Allowed" }.to_json)
      res.status = 405
    end
  end

  def index(req, res, _user_data)
    res['Content-Type'] = 'application/json'
    res.write({ products: @@products }.to_json)
    res.status = 200
  end

  def show(req, res, _user_data)
    id = req.path_info.split('/').last
    product = @@products.find { |p| p[:id] == id }

    if product
      res['Content-Type'] = 'application/json'
      res.write(product.to_json)
      res.status = 200
    else
      res['Content-Type'] = 'application/json'
      res.write({ error: "Product not found" }.to_json)
      res.status = 404
    end
  end

  def update(req, res, _user_data)
    id = req.path_info.split('/').last
    product = @@products.find { |p| p[:id] == id }

    if product
      name = req.params['name']
      if name
        product[:name] = name
        res['Content-Type'] = 'application/json'
        res.write({ message: "Product updated successfully", product: product }.to_json)
        res.status = 200
      else
        res['Content-Type'] = 'application/json'
        res.write({ error: "Missing parameter: 'name'" }.to_json)
        res.status = 400
      end
    else
      res['Content-Type'] = 'application/json'
      res.write({ error: "Product not found" }.to_json)
      res.status = 404
    end
  end

  def delete(req, res, _user_data)
    id = req.path_info.split('/').last
    product = @@products.find { |p| p[:id] == id }

    if product
      @@products.delete(product)
      res['Content-Type'] = 'application/json'
      res.write({ message: "Product deleted successfully" }.to_json)
      res.status = 200
    else
      res['Content-Type'] = 'application/json'
      res.write({ error: "Product not found" }.to_json)
      res.status = 404
    end
  end
end
