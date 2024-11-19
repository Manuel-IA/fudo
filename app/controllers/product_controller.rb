class ProductController
  @@products = []
  @@queue = Queue.new
  @@queue_monitor = Monitor.new # Monitor to synchronize queue

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

      if @@products.any? { |p| p[:id] == id } || product_in_queue?(id)
        res['Content-Type'] = 'application/json'
        res.write({ error: "Product with ID #{id} already exists" }.to_json)
        res.status = 409
        return
      end

      @@queue << { id: id, name: name }

      res['Content-Type'] = 'application/json'
      res.write({ message: "Product creation is in progress", id: id }.to_json)
      res.status = 202
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

  def process_queue
    Thread.new do
      loop do
        if !@@queue.empty?
          job = @@queue.pop
          puts "Processing product: #{job[:id]}"
          sleep(5)
          @@products << job
          puts "Product added: #{job[:id]}"
        end
        sleep(1)
      end
    end
  end

  private

  def product_in_queue?(id)
    @@queue_monitor.synchronize do
      temp_queue = []
      found = false

      until @@queue.empty?
        job = @@queue.pop
        temp_queue << job
        found ||= job[:id] == id
      end

      temp_queue.each { |job| @@queue << job }
      found
    end
  end
end
