Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "127.0.0.1:5500"
    resource "*", headers: :any, methods: [:get, :post, :patch, :put]
  end
end
